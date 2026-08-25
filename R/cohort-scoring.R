# Batch scoring of a cohort's instrument responses into interop-ready
# ClinicalScore objects. The FHIR / OMOP / CDISC exporters already consume a list
# of ClinicalScore keyed by subject_id; this bridges a per-subject response table
# (as held alongside a cohort's data) to that list, so the exporters can be
# driven from the core data model rather than from hand-built scores.

#' Score a cohort's instrument responses into interop-ready ClinicalScores
#'
#' Scores a per-subject table of instrument responses into a list of
#' [ClinicalScore] objects, each tagged with its `subject_id`, ready to drive the
#' FHIR / OMOP / CDISC exporters ([writeFHIRBundle()], [toOMOP()],
#' [toCDISC_QS()]) directly. The `subject_col` and item columns can come straight
#' from a cohort's data (e.g. a `PhysioCohort` subject table joined to captured
#' responses).
#'
#' @param responses A data.frame: one row per subject, with a subject-id column
#'   and one column per instrument item (columns not matching an item are
#'   ignored).
#' @param instrument A [ClinicalInstrument] or an instrument id (resolved via
#'   [getInstrument()]).
#' @param subject_col Name of the subject-id column (default `"subject_id"`).
#' @param timestamp_col Optional name of a timestamp column stored on each score.
#' @param missing Missing-data policy passed to [scoreInstrument()] (default
#'   `"error"`; use `"prorate"` / `"na"` when only some items are present).
#' @return A named list (by subject id) of [ClinicalScore] objects.
#' @seealso [scoreInstrument()], [writeFHIRBundle()], [toOMOP()], [toCDISC_QS()]
#' @export
#' @examples
#' items <- getInstrument("katz_adl")@items
#' resp <- data.frame(subject_id = c("P01", "P02"),
#'   stats::setNames(as.data.frame(rbind(rep(1, 6), c(1, 0, 1, 1, 0, 1))), items))
#' scores <- scoreCohort(resp, "katz_adl")
#' vapply(scores, function(s) s@total, numeric(1))
scoreCohort <- function(responses, instrument, subject_col = "subject_id",
                        timestamp_col = NULL,
                        missing = c("error", "prorate", "na")) {
  missing <- match.arg(missing)
  if (is.character(instrument)) instrument <- getInstrument(instrument)
  responses <- as.data.frame(responses, stringsAsFactors = FALSE)
  if (!subject_col %in% names(responses)) {
    stop(sprintf("'responses' has no subject column '%s'.", subject_col),
         call. = FALSE)
  }
  present <- intersect(instrument@items, names(responses))
  if (!length(present)) {
    stop("none of the instrument's items are columns in 'responses'.",
         call. = FALSE)
  }
  out <- lapply(seq_len(nrow(responses)), function(i) {
    row <- responses[i, , drop = FALSE]
    vals <- stats::setNames(as.numeric(unlist(row[present])), present)
    scoreInstrument(instrument, vals,
                    subject_id = as.character(row[[subject_col]]),
                    timestamp = if (!is.null(timestamp_col))
                      as.character(row[[timestamp_col]]) else NA_character_,
                    missing = missing)
  })
  stats::setNames(out, as.character(responses[[subject_col]]))
}
