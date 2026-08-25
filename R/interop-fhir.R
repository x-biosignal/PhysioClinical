# FHIR R4 Observation export for clinical scores (WS7-02 ClinicalScore).

.loinc_cache <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      f <- system.file("extdata", "interop", "loinc_map.csv",
                       package = "PhysioClinical")
      if (!nzchar(f)) stop("the packaged LOINC map is missing.", call. = FALSE)
      cache <<- utils::read.csv(f, stringsAsFactors = FALSE, colClasses = "character")
    }
    cache
  }
})

.loinc_lookup <- function(instrument, subscale) {
  tbl <- .loinc_cache()
  row <- tbl[tolower(tbl$instrument) == tolower(instrument) &
               tolower(tbl$subscale) == tolower(subscale), , drop = FALSE]
  if (nrow(row) == 0L) return(NULL)
  as.list(row[1L, ])
}

.nz <- function(x) !is.null(x) && length(x) == 1L && !is.na(x) && nzchar(x)

.fhir_codeable <- function(instrument, subscale, fallback_text) {
  m <- .loinc_lookup(instrument, subscale)
  display <- if (!is.null(m) && .nz(m$display)) m$display else fallback_text
  if (!is.null(m) && .nz(m$loinc_code)) {
    list(coding = list(list(system = "http://loinc.org", code = m$loinc_code,
                            display = display)),
         text = display)
  } else {
    list(text = display)   # text-only CodeableConcept (valid FHIR)
  }
}

.fhir_quantity <- function(value, ucum_unit) {
  q <- list(value = as.numeric(value))
  if (.nz(ucum_unit)) {
    q$unit <- ucum_unit
    q$system <- "http://unitsofmeasure.org"
    q$code <- ucum_unit
  }
  q
}

.fhir_unit <- function(instrument, subscale) {
  m <- .loinc_lookup(instrument, subscale)
  if (!is.null(m) && .nz(m$ucum_unit)) m$ucum_unit else "{score}"
}

.fhir_absent <- function() {
  list(coding = list(list(
    system = "http://terminology.hl7.org/CodeSystem/data-absent-reason",
    code = "unknown")))
}

# A bare id becomes Patient/<id>; an id that already looks like a reference
# (contains a "/", or a "urn:" / URL scheme) is used verbatim, so we never emit
# "Patient/Patient/123" or "Patient/urn:uuid:...".
.fhir_subject_ref <- function(id) {
  if (grepl("/", id, fixed = TRUE) || grepl("^[A-Za-z][A-Za-z0-9+.-]*:", id)) {
    id
  } else {
    paste0("Patient/", id)
  }
}

#' Export a clinical score as a FHIR R4 Observation
#'
#' Serializes a \code{\linkS4class{ClinicalScore}} into an HL7 FHIR R4
#' \code{Observation} resource (as a \pkg{jsonlite}-ready list): a survey-category
#' Observation whose \code{code} uses the LOINC map (falling back to a text-only
#' code), the total as \code{valueQuantity}, and each subscale as a
#' \code{component}. Provenance can be attached via \code{derivedFrom}.
#'
#' @param score A \code{\linkS4class{ClinicalScore}}.
#' @param subject Subject reference (e.g. \code{"Patient/123"}); used verbatim.
#'   Defaults to the score's \code{subject_id}: a bare id becomes
#'   \code{"Patient/<id>"}, while an id that is already a reference (contains a
#'   \code{"/"} or a \code{urn:}/URL scheme) is used as-is.
#' @param effectiveDateTime ISO-8601 datetime; defaults to the score's timestamp.
#' @param derivedFrom Optional character vector of source references.
#' @return A \code{"fhir_observation"} list.
#' @references HL7 FHIR R4 Observation; LOINC.
#' @seealso [writeFHIRBundle()], [validateFHIRObservation()]
#' @examples
#' sc <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
#'                    subject_id = "P01", timestamp = "2026-07-26T09:00:00Z")
#' toFHIRObservation(sc)
#' @importFrom methods is
#' @export
toFHIRObservation <- function(score, subject = NULL, effectiveDateTime = NULL,
                              derivedFrom = NULL) {
  if (!methods::is(score, "ClinicalScore")) {
    stop("'score' must be a ClinicalScore.", call. = FALSE)
  }
  inst <- score@instrument_id
  if (!.nz(inst)) stop("the score has no instrument_id.", call. = FALSE)

  subj <- if (!is.null(subject)) as.character(subject)
    else if (.nz(score@subject_id)) .fhir_subject_ref(score@subject_id)
    else NULL
  eff <- if (!is.null(effectiveDateTime)) as.character(effectiveDateTime)
    else if (.nz(score@timestamp)) score@timestamp else NULL

  obs <- list(
    resourceType = "Observation",
    status = "final",
    category = list(list(coding = list(list(
      system = "http://terminology.hl7.org/CodeSystem/observation-category",
      code = "survey", display = "Survey")))),
    code = .fhir_codeable(inst, "total", inst))
  if (!is.null(subj)) obs$subject <- list(reference = subj)
  if (!is.null(eff)) obs$effectiveDateTime <- eff
  # a non-finite score has no valid valueQuantity; FHIR uses dataAbsentReason
  if (is.finite(score@total)) {
    obs$valueQuantity <- .fhir_quantity(score@total, .fhir_unit(inst, "total"))
  } else {
    obs$dataAbsentReason <- .fhir_absent()
  }

  if (length(score@subscales)) {
    # index positionally so a duplicated subscale name cannot alias values
    obs$component <- lapply(seq_along(score@subscales), function(i) {
      sub <- names(score@subscales)[i]
      comp <- list(code = .fhir_codeable(inst, sub, sub))
      v <- score@subscales[[i]]
      if (is.finite(v)) {
        comp$valueQuantity <- .fhir_quantity(v, .fhir_unit(inst, sub))
      } else {
        comp$dataAbsentReason <- .fhir_absent()
      }
      comp
    })
  }
  if (!is.null(derivedFrom)) {
    obs$derivedFrom <- lapply(as.character(derivedFrom),
                              function(r) list(reference = r))
  }
  class(obs) <- c("fhir_observation", "list")
  obs
}

#' Write a FHIR Bundle of clinical-score Observations
#'
#' @param scores A \code{\linkS4class{ClinicalScore}}, an
#'   \code{"fhir_observation"}, or a list of either.
#' @param path Output \code{.json} path.
#' @return \code{path}, invisibly.
#' @seealso [toFHIRObservation()]
#' @export
writeFHIRBundle <- function(scores, path) {
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("writeFHIRBundle() requires the 'jsonlite' package.", call. = FALSE)
  }
  if (methods::is(scores, "ClinicalScore") ||
      inherits(scores, "fhir_observation")) {
    scores <- list(scores)
  }
  obs <- lapply(scores, function(s) {
    if (inherits(s, "fhir_observation")) s else toFHIRObservation(s)
  })
  bundle <- list(resourceType = "Bundle", type = "collection",
                 entry = lapply(obs, function(o) {
                   class(o) <- "list"
                   list(resource = o)
                 }))
  jsonlite::write_json(bundle, path, auto_unbox = TRUE, pretty = TRUE,
                       null = "null")
  invisible(path)
}

#' Validate a FHIR Observation against the bundled JSON schema
#'
#' @param obs An \code{"fhir_observation"} (or a list).
#' @return \code{TRUE} if valid; otherwise \code{FALSE} with the validation
#'   errors as an attribute (requires \pkg{jsonvalidate}).
#' @seealso [toFHIRObservation()]
#' @export
validateFHIRObservation <- function(obs) {
  if (!requireNamespace("jsonvalidate", quietly = TRUE) ||
      !requireNamespace("jsonlite", quietly = TRUE)) {
    stop("validateFHIRObservation() requires 'jsonvalidate' and 'jsonlite'.",
         call. = FALSE)
  }
  schema <- system.file("extdata", "interop", "fhir_observation.schema.json",
                        package = "PhysioClinical")
  class(obs) <- "list"
  json <- jsonlite::toJSON(obs, auto_unbox = TRUE, null = "null")
  jsonvalidate::json_validate(json, schema, engine = "ajv", verbose = TRUE)
}

#' @export
print.fhir_observation <- function(x, ...) {
  cat("<fhir_observation> Observation/", x$status, "\n", sep = "")
  cd <- if (!is.null(x$code$coding)) x$code$coding[[1L]]$code else x$code$text
  cat("  code:   ", cd, "\n")
  if (!is.null(x$subject)) cat("  subject:", x$subject$reference, "\n")
  cat("  value:  ", x$valueQuantity$value,
      if (!is.null(x$valueQuantity$unit)) x$valueQuantity$unit else "", "\n")
  if (!is.null(x$component)) {
    cat("  components:", length(x$component), "\n")
  }
  invisible(x)
}
