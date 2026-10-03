# Typed convenience wrappers for the bundled pain instruments, each delegating
# to scoreInstrument() on the corresponding bundled YAML spec.
#
# The single-item Numeric Rating Scale (0-10) is the everyday intensity measure;
# the Brief Pain Inventory adds the multi-item severity and interference
# subscales. Both are directed higher_worse (a higher score is more pain).

#' Score a Pain Numeric Rating Scale (0-10)
#'
#' A single 0-10 pain-intensity rating, banded into the conventional none / mild
#' / moderate / severe strata. An equivalent 0-100 mm Visual Analogue Scale
#' measures the same construct on a wider range.
#'
#' @param items The pain rating: a length-1 numeric, or a named vector
#'   `c(pain_intensity = x)`.
#' @param ... Passed to [scoreInstrument()] (e.g. `subject_id`).
#' @return A [ClinicalScore] with the rating (0-10) and its severity stratum.
#' @seealso [scoreBPI()]
#' @export
#' @examples
#' scorePainNRS(c(pain_intensity = 6))
scorePainNRS <- function(items, ...) scoreInstrument("pain_nrs", items, ...)

#' Score the Brief Pain Inventory (short form)
#'
#' Scores the BPI severity (worst / least / average / current pain) and
#' interference (general activity, mood, walking, work, relations, sleep,
#' enjoyment of life) items, each 0-10. Severity and interference are reported
#' as their mean subscale scores (each 0-10, the conventional BPI summaries);
#' the total is the grand mean over all items.
#'
#' @param items Named numeric responses (e.g. `worst_pain = 8`,
#'   `interference_sleep = 5`) or an unnamed vector in the instrument's item
#'   order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing = "prorate"`).
#' @return A [ClinicalScore] whose `subscales` hold the severity and
#'   interference means.
#' @seealso [scorePainNRS()], [getInstrument()]
#' @export
#' @examples
#' scoreBPI(stats::setNames(c(8, 2, 5, 4, 5, 6, 5, 7, 3, 5, 6),
#'                          getInstrument("bpi")@items))
scoreBPI <- function(items, ...) scoreInstrument("bpi", items, ...)
