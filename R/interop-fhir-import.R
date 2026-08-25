# Import path for FHIR: parse a FHIR R4 Observation back into a ClinicalScore,
# inverting toFHIRObservation(). This is closed-world (it inverts this package's
# own serialization via the same bundled LOINC map) so it is fully offline. Three
# slots are genuinely lossy because toFHIRObservation never writes them:
# items_used and missing_handling are unrecoverable, and stratum is re-derived
# from the total when the instrument is registered.

# Reverse a FHIR CodeableConcept to an instrument or subscale name using the
# bundled LOINC map: a LOINC-coded concept reverse-looks-up by code, otherwise
# the text is matched to a display (else taken verbatim).
.fhir_decode <- function(codeable, which = c("instrument", "subscale")) {
  which <- match.arg(which)
  if (!is.list(codeable)) return(NA_character_)
  tbl <- .loinc_cache()
  coding <- codeable$coding
  first <- if (length(coding)) coding[[1]] else NULL
  if (!is.null(first) && identical(first$system, "http://loinc.org") &&
      .nz(first$code)) {
    row <- tbl[tbl$loinc_code == first$code, , drop = FALSE]
    if (nrow(row)) return(as.character(row[[which]][1]))
  }
  txt <- if (.nz(codeable$text)) codeable$text
    else if (!is.null(first) && .nz(first$display)) first$display else NULL
  if (!is.null(txt)) {
    row <- tbl[tolower(tbl$display) == tolower(txt), , drop = FALSE]
    if (nrow(row)) return(as.character(row[[which]][1]))
    return(txt)                         # verbatim (unmapped id, or the name)
  }
  NA_character_
}

.fhir_value <- function(node) {
  if (is.list(node$valueQuantity) && !is.null(node$valueQuantity$value)) {
    as.numeric(node$valueQuantity$value)
  } else NA_real_                        # dataAbsentReason -> NA
}

#' Import a FHIR R4 Observation as a clinical score
#'
#' Parses an HL7 FHIR R4 \code{Observation} (as produced by
#' \code{\link{toFHIRObservation}}) back into a \code{\linkS4class{ClinicalScore}},
#' the import counterpart of the \code{to*}/\code{write*} exporters. The
#' \code{instrument_id} and each subscale name are recovered from the bundled
#' LOINC map (reverse code lookup, then display, then the verbatim text); the
#' \code{total} and subscale values come from \code{valueQuantity} (a
#' \code{dataAbsentReason} becomes \code{NA}); the subject id strips a leading
#' \code{"Patient/"}; and the timestamp comes from \code{effectiveDateTime}.
#'
#' The round-trip is lossy for three slots that \code{\link{toFHIRObservation}}
#' does not serialize: \code{items_used} and \code{missing_handling} cannot be
#' recovered, and \code{stratum} is re-derived from the total only when the
#' instrument is registered (via \code{\link{getInstrument}}), otherwise
#' \code{NA}.
#'
#' @param observation A FHIR Observation as a list (a \code{\link{toFHIRObservation}}
#'   result or a parsed \pkg{jsonlite} object), a JSON string, or a path to a
#'   \code{.json} file.
#' @return A \code{\linkS4class{ClinicalScore}}.
#' @seealso \code{\link{toFHIRObservation}}, \code{\link{writeFHIRBundle}}
#' @importFrom methods new
#' @export
#' @examples
#' sc <- scoreInstrument("katz_adl",
#'   stats::setNames(rep(1, 6), getInstrument("katz_adl")@items),
#'   subject_id = "P01")
#' fromFHIR(toFHIRObservation(sc))@total
fromFHIR <- function(observation) {
  obs <- observation
  if (is.character(obs) && length(obs) == 1L) {
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
      stop("reading FHIR JSON needs the 'jsonlite' package.", call. = FALSE)
    }
    obs <- if (file.exists(obs)) {
      jsonlite::read_json(obs, simplifyVector = FALSE)
    } else jsonlite::fromJSON(obs, simplifyVector = FALSE)
  }
  if (!is.list(obs) || !identical(obs$resourceType, "Observation")) {
    stop("'observation' must be a FHIR Observation (list, JSON string, or path).",
         call. = FALSE)
  }

  instrument_id <- .fhir_decode(obs$code, "instrument")
  total <- .fhir_value(obs)
  subs <- stats::setNames(numeric(0), character(0))
  if (length(obs$component)) {
    nm <- vapply(obs$component, function(cp) .fhir_decode(cp$code, "subscale"),
                 character(1))
    val <- vapply(obs$component, .fhir_value, numeric(1))
    subs <- stats::setNames(val, nm)
  }
  subject_id <- if (is.list(obs$subject) && .nz(obs$subject$reference)) {
    sub("^Patient/", "", as.character(obs$subject$reference))
  } else NA_character_
  timestamp <- if (.nz(obs$effectiveDateTime)) as.character(obs$effectiveDateTime) else
    NA_character_

  # re-derive the interpretation stratum when the instrument is registered
  stratum <- NA_character_
  if (.nz(instrument_id) && is.finite(total)) {
    inst <- tryCatch(getInstrument(instrument_id), error = function(e) NULL)
    if (!is.null(inst)) stratum <- assignStratum(inst, total)
  }

  methods::new("ClinicalScore",
    instrument_id = as.character(instrument_id), total = total,
    subscales = subs, stratum = as.character(stratum),
    items_used = character(0), missing_handling = NA_character_,
    timestamp = timestamp, subject_id = as.character(subject_id))
}
