# OMOP CDM v5.4 export for clinical scores (WS7-02 ClinicalScore).
# A ClinicalScore becomes one or more MEASUREMENT / OBSERVATION rows: the total
# and each subscale is a row, routed by the concept map's domain_id. Concept ids
# come from the packaged concept map; unmapped entries fall back to 0 (the OMOP
# "No matching concept") with a warning. No Athena concept ids are fabricated.

.omop_concept_cache <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      f <- system.file("extdata", "interop", "omop_concept_map.csv",
                       package = "PhysioClinical")
      if (!nzchar(f)) stop("the packaged OMOP concept map is missing.",
                           call. = FALSE)
      cache <<- utils::read.csv(f, stringsAsFactors = FALSE,
                                colClasses = "character")
    }
    cache
  }
})

.omop_lookup <- function(instrument, subscale, map = NULL) {
  tbl <- if (is.null(map)) .omop_concept_cache() else map
  row <- tbl[tolower(tbl$instrument) == tolower(instrument) &
               tolower(tbl$subscale) == tolower(subscale), , drop = FALSE]
  if (nrow(row) == 0L) return(NULL)
  as.list(row[1L, ])
}

# A blank / malformed concept cell -> 0L (OMOP "No matching concept"). A cell
# that is not a plain non-negative integer (e.g. "12.9", "-5", overflow) is
# rejected with a warning rather than silently truncated to a wrong id.
.omop_cid <- function(x) {
  if (!.nz(x)) return(0L)
  xs <- trimws(x)
  v <- if (grepl("^[0-9]+$", xs)) suppressWarnings(as.integer(xs)) else NA_integer_
  if (is.na(v)) {
    warning("concept_id '", x, "' is not a valid non-negative integer; ",
            "using 0 (No matching concept).", call. = FALSE)
    return(0L)
  }
  v
}

# person_id must be a non-null integer. Use an explicit person_map first, then
# an integer-like subject_id; otherwise NA (with the id collected for a warning).
.omop_person_id <- function(subject_id, person_map, unresolved) {
  if (!.nz(subject_id)) {
    unresolved$ids <- c(unresolved$ids, "<missing subject_id>")
    return(list(id = NA_integer_, unresolved = unresolved))
  }
  if (!is.null(person_map) && subject_id %in% names(person_map)) {
    return(list(id = as.integer(person_map[[subject_id]]),
                unresolved = unresolved))
  }
  # only a plain positive-integer id is used directly (no "1e3"/"1.0"/" 5 "
  # surprises); anything else needs an explicit person_map.
  if (grepl("^[0-9]+$", subject_id) && as.numeric(subject_id) > 0) {
    return(list(id = as.integer(subject_id), unresolved = unresolved))
  }
  unresolved$ids <- c(unresolved$ids, subject_id)
  list(id = NA_integer_, unresolved = unresolved)
}

.omop_date <- function(timestamp) {
  if (!.nz(timestamp)) return(list(date = NA_character_, datetime = NA_character_))
  dt <- sub("Z$", "", gsub("T", " ", timestamp))
  d <- tryCatch(as.character(as.Date(substr(timestamp, 1L, 10L))),
                error = function(e) NA_character_)
  list(date = d, datetime = dt)
}

.omop_measurement_schema <- function() {
  data.frame(
    measurement_id = integer(0), person_id = integer(0),
    measurement_concept_id = integer(0), measurement_date = character(0),
    measurement_datetime = character(0), measurement_type_concept_id = integer(0),
    value_as_number = numeric(0), value_as_concept_id = integer(0),
    unit_concept_id = integer(0), measurement_source_value = character(0),
    measurement_source_concept_id = integer(0), unit_source_value = character(0),
    value_source_value = character(0), stringsAsFactors = FALSE)
}

.omop_observation_schema <- function() {
  data.frame(
    observation_id = integer(0), person_id = integer(0),
    observation_concept_id = integer(0), observation_date = character(0),
    observation_datetime = character(0), observation_type_concept_id = integer(0),
    value_as_number = numeric(0), value_as_string = character(0),
    value_as_concept_id = integer(0), unit_concept_id = integer(0),
    observation_source_value = character(0),
    observation_source_concept_id = integer(0), unit_source_value = character(0),
    stringsAsFactors = FALSE)
}

#' Export clinical scores to OMOP CDM v5.4 tables
#'
#' Maps one or more \code{\linkS4class{ClinicalScore}} objects to OMOP Common
#' Data Model v5.4 \code{MEASUREMENT} and \code{OBSERVATION} rows. The total and
#' each subscale become a row, routed to \code{MEASUREMENT} or \code{OBSERVATION}
#' by the concept map's \code{domain_id}. Concept ids are looked up in the
#' packaged \code{omop_concept_map.csv}; an unmapped instrument yields
#' \code{measurement_concept_id = 0} (the OMOP "No matching concept") with a
#' warning. No Athena concept ids are fabricated — the shipped map leaves them
#' blank; supply a site \code{concept_map} to populate them.
#'
#' @param scores A \code{\linkS4class{ClinicalScore}} or a list of them.
#' @param concept_map Optional data frame overriding the packaged concept map
#'   (columns \code{instrument}, \code{subscale}, \code{domain_id},
#'   \code{measurement_concept_id}, \code{unit_concept_id}).
#' @param person_map Optional named vector/list mapping \code{subject_id} to an
#'   integer \code{person_id}. When absent, a plain positive-integer
#'   \code{subject_id} (matching \code{"^[0-9]+$"}) is used directly; any other
#'   id is left as \code{NA} with a warning.
#' @param type_concept_id Integer \code{*_type_concept_id} for provenance
#'   (default \code{0L} = "No matching concept"); set to your site's type
#'   concept (e.g. EHR).
#' @return A list with \code{MEASUREMENT} and \code{OBSERVATION} data frames
#'   conforming to the OMOP CDM v5.4 column layout.
#' @references OHDSI OMOP CDM v5.4 (MEASUREMENT, OBSERVATION).
#' @seealso [writeOMOPTables()], [toFHIRObservation()]
#' @examples
#' sc <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
#'                    subject_id = "1001", timestamp = "2026-07-26T09:00:00Z")
#' suppressWarnings(toOMOP(sc))
#' @export
toOMOP <- function(scores, concept_map = NULL, person_map = NULL,
                   type_concept_id = 0L) {
  if (methods::is(scores, "ClinicalScore")) scores <- list(scores)
  if (!is.list(scores) || !length(scores) ||
      !all(vapply(scores, methods::is, logical(1), "ClinicalScore"))) {
    stop("'scores' must be a ClinicalScore or a non-empty list of them.",
         call. = FALSE)
  }
  type_concept_id <- as.integer(type_concept_id)
  m_rows <- list(); o_rows <- list()
  unresolved <- new.env(parent = emptyenv()); unresolved$ids <- character(0)
  unresolved_pm <- list(ids = character(0))
  unmapped <- character(0)

  for (sc in scores) {
    inst <- sc@instrument_id
    if (!.nz(inst)) stop("a score has no instrument_id.", call. = FALSE)
    pr <- .omop_person_id(sc@subject_id, person_map, unresolved_pm)
    pid <- pr$id; unresolved_pm <- pr$unresolved
    dt <- .omop_date(sc@timestamp)

    # index subscales positionally: a duplicated subscale name would make a
    # by-name lookup return the first match for every row (value/name mismatch).
    entries <- c(list(list(sub = "total", val = sc@total)),
                 lapply(seq_along(sc@subscales),
                        function(i) list(sub = names(sc@subscales)[i],
                                         val = sc@subscales[[i]])))
    for (e in entries) {
      m <- .omop_lookup(inst, e$sub, concept_map)
      domain <- if (!is.null(m) && .nz(m$domain_id)) m$domain_id else "Measurement"
      cid <- if (is.null(m)) 0L else .omop_cid(m$measurement_concept_id)
      if (cid == 0L) unmapped <- c(unmapped, paste0(inst, ":", e$sub))
      unit_cid <- if (is.null(m)) 0L else .omop_cid(m$unit_concept_id)
      unit_src <- .fhir_unit(inst, e$sub)   # UCUM string from the LOINC map
      src_val <- if (identical(e$sub, "total")) inst else paste0(inst, ":", e$sub)
      val <- if (is.finite(e$val)) as.numeric(e$val) else NA_real_

      if (tolower(domain) == "observation") {
        o_rows[[length(o_rows) + 1L]] <- data.frame(
          observation_id = NA_integer_, person_id = pid,
          observation_concept_id = cid, observation_date = dt$date,
          observation_datetime = dt$datetime,
          observation_type_concept_id = type_concept_id,
          value_as_number = val, value_as_string = NA_character_,
          value_as_concept_id = NA_integer_, unit_concept_id = unit_cid,
          observation_source_value = src_val,
          observation_source_concept_id = 0L, unit_source_value = unit_src,
          stringsAsFactors = FALSE)
      } else {
        m_rows[[length(m_rows) + 1L]] <- data.frame(
          measurement_id = NA_integer_, person_id = pid,
          measurement_concept_id = cid, measurement_date = dt$date,
          measurement_datetime = dt$datetime,
          measurement_type_concept_id = type_concept_id,
          value_as_number = val, value_as_concept_id = NA_integer_,
          unit_concept_id = unit_cid, measurement_source_value = src_val,
          measurement_source_concept_id = 0L, unit_source_value = unit_src,
          value_source_value = if (is.finite(e$val)) as.character(e$val) else NA_character_,
          stringsAsFactors = FALSE)
      }
    }
  }

  meas <- if (length(m_rows)) do.call(rbind, m_rows) else .omop_measurement_schema()
  obs  <- if (length(o_rows)) do.call(rbind, o_rows) else .omop_observation_schema()
  if (nrow(meas)) meas$measurement_id <- seq_len(nrow(meas))
  if (nrow(obs))  obs$observation_id  <- seq_len(nrow(obs))

  if (length(unmapped)) {
    warning("no OMOP concept_id for: ",
            paste(unique(unmapped), collapse = ", "),
            " (mapped to 0). Supply a site concept_map to resolve.",
            call. = FALSE)
  }
  if (length(unresolved_pm$ids)) {
    warning("could not resolve person_id for subject_id: ",
            paste(unique(unresolved_pm$ids), collapse = ", "),
            " (person_id is NA). Supply a person_map.", call. = FALSE)
  }
  list(MEASUREMENT = meas, OBSERVATION = obs)
}

#' Write OMOP CDM tables to CSV files
#'
#' Writes each non-empty table from [toOMOP()] to \code{<path>/<table>.csv}
#' (lower-cased, e.g. \code{measurement.csv}), following the one-file-per-table
#' OMOP convention.
#'
#' @param tables A \code{\linkS4class{ClinicalScore}}, a list of them, or the
#'   list returned by [toOMOP()].
#' @param path Output directory (created if needed).
#' @return A character vector of written file paths, invisibly.
#' @seealso [toOMOP()]
#' @export
writeOMOPTables <- function(tables, path) {
  if (methods::is(tables, "ClinicalScore") ||
      (is.list(tables) && length(tables) &&
       all(vapply(tables, methods::is, logical(1), "ClinicalScore")))) {
    tables <- toOMOP(tables)
  }
  if (!is.list(tables) || !all(c("MEASUREMENT", "OBSERVATION") %in% names(tables))) {
    stop("'tables' must be a ClinicalScore(s) or a toOMOP() result.",
         call. = FALSE)
  }
  if (!dir.exists(path)) dir.create(path, recursive = TRUE)
  written <- character(0)
  for (nm in names(tables)) {
    tbl <- tables[[nm]]
    if (!is.data.frame(tbl) || !nrow(tbl)) next
    f <- file.path(path, paste0(tolower(nm), ".csv"))
    utils::write.csv(tbl, f, row.names = FALSE, na = "")
    written <- c(written, f)
  }
  invisible(written)
}
