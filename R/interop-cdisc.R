# CDISC SDTM (QS domain) and ADaM (BDS) export for clinical scores
# (WS7-02 ClinicalScore). The total and each subscale becomes a QS record. Test
# codes come from the packaged controlled-terminology map; where an instrument
# is unmapped, a sponsor-defined QSTESTCD is derived (<= 8 chars) with a warning.
# QSTESTCD values are marked ct_status "sponsor" in the shipped map - they are
# not asserted to be published CDISC CT; replace them with published CT codes
# where those exist.

.cdisc_ct_cache <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      f <- system.file("extdata", "interop", "cdisc_ct.csv",
                       package = "PhysioClinical")
      if (!nzchar(f)) stop("the packaged CDISC CT map is missing.",
                           call. = FALSE)
      cache <<- utils::read.csv(f, stringsAsFactors = FALSE,
                                colClasses = "character")
    }
    cache
  }
})

.cdisc_lookup <- function(instrument, subscale, map = NULL) {
  tbl <- if (is.null(map)) .cdisc_ct_cache() else map
  row <- tbl[tolower(tbl$instrument) == tolower(instrument) &
               tolower(tbl$subscale) == tolower(subscale), , drop = FALSE]
  if (nrow(row) == 0L) return(NULL)
  as.list(row[1L, ])
}

# A sponsor QSTESTCD when unmapped: upper-cased alphanumerics of the instrument
# (+ subscale when not "total"), forced to start with a letter (the SDTM
# --TESTCD rule) and truncated to the 8-character limit.
.cdisc_derive_testcd <- function(instrument, subscale) {
  base <- if (identical(subscale, "total")) instrument
    else paste0(instrument, subscale)
  code <- toupper(gsub("[^A-Za-z0-9]", "", base))
  if (!nzchar(code)) code <- "QS"
  if (grepl("^[0-9]", code)) code <- paste0("X", code)  # must start with a letter
  substr(code, 1L, 8L)
}

# Make a derived code unique within the QSTESTCD budget: on a collision with an
# already-used code, append a numeric suffix (shrinking the stem to fit 8).
.cdisc_unique_code <- function(code, used) {
  if (!(code %in% used)) return(code)
  for (n in 1:9999) {
    suf <- as.character(n)
    cand <- paste0(substr(code, 1L, 8L - nchar(suf)), suf)
    if (!(cand %in% used)) return(cand)
  }
  stop("could not derive a unique QSTESTCD from '", code, "'.", call. = FALSE)
}

.cdisc_qs_schema <- function() {
  data.frame(
    STUDYID = character(0), DOMAIN = character(0), USUBJID = character(0),
    QSSEQ = integer(0), QSTESTCD = character(0), QSTEST = character(0),
    QSCAT = character(0), QSORRES = character(0), QSORRESU = character(0),
    QSSTRESC = character(0), QSSTRESN = numeric(0), QSSTRESU = character(0),
    VISITNUM = numeric(0), VISIT = character(0), QSDTC = character(0),
    stringsAsFactors = FALSE)
}

#' Export clinical scores to a CDISC SDTM QS (Questionnaires) domain
#'
#' Maps one or more \code{\linkS4class{ClinicalScore}} objects to a CDISC SDTMIG
#' Questionnaires (QS) domain data frame: the total and each subscale becomes a
#' QS record. \code{QSTESTCD}/\code{QSTEST}/\code{QSCAT} come from the packaged
#' controlled-terminology map (\code{cdisc_ct.csv}); an unmapped instrument gets
#' a sponsor-defined \code{QSTESTCD} (upper-cased, forced to start with a letter,
#' disambiguated against collisions, and truncated to the SDTM 8-character limit)
#' with a warning. \code{QSTESTCD} values in the shipped map are sponsor-defined
#' (\code{ct_status = "sponsor"}), not asserted to be published CDISC CT.
#'
#' @param scores A \code{\linkS4class{ClinicalScore}} or a list of them.
#' @param ct_map Optional data frame overriding the packaged CT map (columns
#'   \code{instrument}, \code{subscale}, \code{qstestcd}, \code{qstest},
#'   \code{qscat}).
#' @param studyid \code{STUDYID} value (default \code{"STUDY"}).
#' @param usubjid_map Optional named vector/list mapping \code{subject_id} to a
#'   \code{USUBJID}; otherwise \code{USUBJID = <studyid>-<subject_id>}.
#' @param visitnum,visit \code{VISITNUM} / \code{VISIT} for all records.
#' @return A QS-domain \code{data.frame} conforming to the SDTMIG column layout.
#' @references CDISC SDTMIG QS domain.
#' @seealso [toADaM_ADQS()], [toFHIRObservation()], [toOMOP()]
#' @examples
#' sc <- methods::new("ClinicalScore", instrument_id = "fim", total = 90,
#'                    subscales = c(motor = 60, cognitive = 30),
#'                    subject_id = "01-001", timestamp = "2026-07-26")
#' toCDISC_QS(sc)
#' @export
toCDISC_QS <- function(scores, ct_map = NULL, studyid = "STUDY",
                       usubjid_map = NULL, visitnum = 1L, visit = NA_character_) {
  if (methods::is(scores, "ClinicalScore")) scores <- list(scores)
  if (!is.list(scores) || !length(scores) ||
      !all(vapply(scores, methods::is, logical(1), "ClinicalScore"))) {
    stop("'scores' must be a ClinicalScore or a non-empty list of them.",
         call. = FALSE)
  }
  rows <- list()
  seq_by_subj <- new.env(parent = emptyenv())
  # resolve each distinct (instrument, subscale) to a QSTESTCD/QSTEST/QSCAT once,
  # so repeats stay consistent and derived codes are assigned collision-free.
  reg <- new.env(parent = emptyenv())
  used_codes <- character(0)
  derived <- character(0); no_subject <- FALSE

  for (sc in scores) {
    inst <- sc@instrument_id
    if (!.nz(inst)) stop("a score has no instrument_id.", call. = FALSE)
    usubjid <- if (!is.null(usubjid_map) && .nz(sc@subject_id) &&
                   sc@subject_id %in% names(usubjid_map)) {
      as.character(usubjid_map[[sc@subject_id]])
    } else if (.nz(sc@subject_id)) {
      paste0(studyid, "-", sc@subject_id)
    } else {
      no_subject <- TRUE; NA_character_
    }
    qsdtc <- if (.nz(sc@timestamp)) sc@timestamp else NA_character_

    entries <- c(list(list(sub = "total", val = sc@total)),
                 lapply(seq_along(sc@subscales),
                        function(i) list(sub = names(sc@subscales)[i],
                                         val = sc@subscales[[i]])))
    for (e in entries) {
      rk <- paste0(tolower(inst), "||", tolower(e$sub))
      if (is.null(reg[[rk]])) {
        m <- .cdisc_lookup(inst, e$sub, ct_map)
        if (!is.null(m) && .nz(m$qstestcd)) {
          testcd <- m$qstestcd
          qstest <- if (.nz(m$qstest)) m$qstest else inst
        } else {
          derived <- c(derived, paste0(inst, ":", e$sub))
          testcd <- .cdisc_unique_code(.cdisc_derive_testcd(inst, e$sub),
                                       used_codes)
          # differentiate the derived test name per subscale (one-to-one)
          qstest <- if (identical(e$sub, "total")) inst
            else paste0(inst, " ", e$sub)
        }
        if (nchar(testcd) > 8L) {
          stop(sprintf("QSTESTCD '%s' exceeds the SDTM 8-character limit.",
                       testcd), call. = FALSE)
        }
        if (nchar(qstest) > 40L) {
          stop(sprintf("QSTEST '%s' exceeds the SDTM 40-character limit.",
                       qstest), call. = FALSE)
        }
        qscat <- if (!is.null(m) && .nz(m$qscat)) m$qscat else NA_character_
        reg[[rk]] <- list(testcd = testcd, qstest = qstest, qscat = qscat)
        used_codes <- c(used_codes, testcd)
      }
      r <- reg[[rk]]
      unit <- .fhir_unit(inst, e$sub)
      unit <- if (identical(unit, "{score}")) NA_character_ else unit
      val <- if (is.finite(e$val)) as.numeric(e$val) else NA_real_
      # plain decimal, never scientific notation (keeps QSORRES/QSSTRESC == QSSTRESN)
      valc <- if (is.finite(e$val)) format(e$val, scientific = FALSE, trim = TRUE)
        else NA_character_

      key <- if (is.na(usubjid)) "<NA>" else usubjid
      nxt <- (if (is.null(seq_by_subj[[key]])) 0L else seq_by_subj[[key]]) + 1L
      seq_by_subj[[key]] <- nxt

      rows[[length(rows) + 1L]] <- data.frame(
        STUDYID = studyid, DOMAIN = "QS", USUBJID = usubjid, QSSEQ = nxt,
        QSTESTCD = r$testcd, QSTEST = r$qstest, QSCAT = r$qscat,
        QSORRES = valc, QSORRESU = unit, QSSTRESC = valc, QSSTRESN = val,
        QSSTRESU = unit, VISITNUM = as.numeric(visitnum),
        VISIT = as.character(visit), QSDTC = qsdtc, stringsAsFactors = FALSE)
    }
  }

  if (length(derived)) {
    warning("no CDISC CT for: ", paste(unique(derived), collapse = ", "),
            " (used a sponsor-defined QSTESTCD). Supply a ct_map to resolve.",
            call. = FALSE)
  }
  if (no_subject) {
    warning("a score has no subject_id; USUBJID is NA. Supply usubjid_map.",
            call. = FALSE)
  }
  if (!length(rows)) return(.cdisc_qs_schema())
  qs <- do.call(rbind, rows)
  # SDTM requires QSTESTCD <-> QSTEST to be one-to-one; catch a bad ct_map.
  pairs <- unique(qs[, c("QSTESTCD", "QSTEST")])
  dup <- pairs$QSTESTCD[duplicated(pairs$QSTESTCD)]
  if (length(dup)) {
    stop("QSTESTCD maps to multiple QSTEST (not one-to-one): ",
         paste(unique(dup), collapse = ", "), call. = FALSE)
  }
  qs
}

#' Export clinical scores to an ADaM BDS (ADQS) data frame
#'
#' Restructures a QS domain (or scores) into an ADaM Basic Data Structure
#' analysis data set (one \code{PARAMCD} per test): \code{AVAL}/\code{AVALC}
#' carry the numeric/character result and \code{PARCAT1} the questionnaire
#' category.
#'
#' @param x A \code{\linkS4class{ClinicalScore}}, a list of them, or a QS-domain
#'   data frame from [toCDISC_QS()].
#' @param ... Passed to [toCDISC_QS()] when \code{x} is score(s).
#' @return An ADaM BDS \code{data.frame} (columns \code{STUDYID},
#'   \code{USUBJID}, \code{PARAMCD}, \code{PARAM}, \code{PARCAT1}, \code{AVAL},
#'   \code{AVALC}, \code{AVISIT}, \code{AVISITN}, \code{ADT}).
#' @references CDISC ADaM Basic Data Structure (BDS).
#' @seealso [toCDISC_QS()]
#' @export
toADaM_ADQS <- function(x, ...) {
  qs <- if (is.data.frame(x)) x else toCDISC_QS(x, ...)
  req <- c("STUDYID", "USUBJID", "QSTESTCD", "QSTEST", "QSCAT",
           "QSSTRESN", "QSSTRESC", "VISITNUM", "QSDTC")
  if (!all(req %in% names(qs))) {
    stop("'x' must be a QS-domain data frame or clinical score(s).",
         call. = FALSE)
  }
  data.frame(
    STUDYID = qs$STUDYID, USUBJID = qs$USUBJID,
    PARAMCD = qs$QSTESTCD, PARAM = qs$QSTEST, PARCAT1 = qs$QSCAT,
    AVAL = qs$QSSTRESN, AVALC = qs$QSSTRESC,
    AVISIT = qs$VISIT, AVISITN = qs$VISITNUM,
    ADT = substr(qs$QSDTC, 1L, 10L), stringsAsFactors = FALSE)
}
