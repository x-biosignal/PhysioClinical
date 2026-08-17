# Typed convenience wrappers for the bundled ADL / IADL instruments, each
# delegating to scoreInstrument() on the corresponding bundled YAML spec.
#
# These are the everyday functional-status measures of rehabilitation,
# geriatrics and epidemiology: the Barthel Index and Katz Index for basic
# activities of daily living (self-care, mobility) and the Lawton-Brody scale
# for instrumental ADL (the complex tasks of independent community living).
# Scored ordinally here; the interval (Rasch) treatment of the same responses
# is raschAnalyze().

#' Score the Barthel Index (basic activities of daily living)
#'
#' The Barthel Index rates ten basic ADL domains on their conventional weighted
#' scale (steps of 5; transfers and mobility to 15) for a total of 0-100, higher
#' being more independent.
#'
#' @param items Named numeric responses on the weighted per-item scale
#'   (e.g. `feeding = 10`, `bathing = 5`, `transfers = 15`), or an unnamed
#'   vector in the instrument's item order. Allowed values are the conventional
#'   weights (0/5/10, and 0/5/10/15 for transfers and mobility).
#' @param ... Passed to [scoreInstrument()] (e.g. `missing`, `subject_id`).
#' @return A [ClinicalScore] with the total (0-100) and the dependence stratum
#'   (total / severe / moderate / slight dependence / independent).
#' @seealso [scoreKatz()], [scoreLawton()], [raschAnalyze()]
#' @export
#' @examples
#' scoreBarthel(stats::setNames(
#'   c(10, 5, 5, 10, 10, 10, 10, 15, 15, 10), getInstrument("barthel")@items))
scoreBarthel <- function(items, ...) scoreInstrument("barthel", items, ...)

#' Score the Katz Index of Independence in ADL
#'
#' Six basic ADL activities (bathing, dressing, toileting, transferring,
#' continence, feeding), each scored independent (1) or dependent (0), for a
#' total of 0-6.
#'
#' @param items Named numeric responses (0/1 per activity) or an unnamed vector
#'   in the instrument's item order.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-6) and the impairment stratum.
#' @seealso [scoreBarthel()], [scoreLawton()]
#' @export
#' @examples
#' scoreKatz(c(bathing = 1, dressing = 1, toileting = 1,
#'             transferring = 1, continence = 0, feeding = 1))
scoreKatz <- function(items, ...) scoreInstrument("katz_adl", items, ...)

#' Score the Lawton-Brody IADL scale (instrumental ADL)
#'
#' Eight instrumental-ADL domains of independent community living (telephone,
#' shopping, food preparation, housekeeping, laundry, transportation,
#' medication, finances), each dichotomised independent (1) / dependent (0),
#' summed to a 0-8 count. Lawton & Brody define no total-score severity bands,
#' so the returned stratum is `NA`.
#'
#' @param items Named numeric responses (0/1 per domain) or an unnamed vector in
#'   the instrument's item order. For the abbreviated male version, omit the
#'   food-preparation, housekeeping and laundry items and use `missing = "na"`.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-8).
#' @seealso [scoreBarthel()], [scoreKatz()], [raschAnalyze()]
#' @export
#' @examples
#' scoreLawton(stats::setNames(rep(1, 8), getInstrument("lawton_iadl")@items))
scoreLawton <- function(items, ...) scoreInstrument("lawton_iadl", items, ...)
