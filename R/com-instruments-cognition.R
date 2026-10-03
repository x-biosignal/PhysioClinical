# Typed convenience wrappers for the bundled cognitive-screening instruments,
# each delegating to scoreInstrument() on the corresponding bundled YAML spec.
#
# The MMSE and MoCA are the two most widely used bedside cognitive screens in
# neurology, geriatrics and rehabilitation. Both are scored 0-30 (higher is
# better); the MoCA is the more sensitive to mild cognitive impairment.

#' Score the Mini-Mental State Examination (MMSE)
#'
#' Sums the eleven MMSE components (orientation to time and place, registration,
#' attention/calculation, recall, naming, repetition, a three-stage command,
#' reading, writing and figure copying) to a total of 0-30, higher being better
#' cognition.
#'
#' @param items Named numeric responses giving the points earned on each
#'   component (e.g. `orientation_time = 5`, `recall = 2`), or an unnamed vector
#'   in the instrument's item order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing`, `subject_id`).
#' @return A [ClinicalScore] with the total (0-30), the six-domain subscale
#'   scores and the impairment stratum (no / mild / severe impairment).
#' @seealso [scoreMoCA()], [getInstrument()]
#' @export
#' @examples
#' scoreMMSE(stats::setNames(c(5, 5, 3, 5, 3, 2, 1, 3, 1, 1, 1),
#'                           getInstrument("mmse")@items))
scoreMMSE <- function(items, ...) scoreInstrument("mmse", items, ...)

#' Score the Montreal Cognitive Assessment (MoCA)
#'
#' Sums the seven MoCA domains (visuospatial/executive, naming, attention,
#' language, abstraction, delayed recall and orientation) to a total of 0-30. A
#' total below 26 indicates cognitive impairment. One point is conventionally
#' added for participants with 12 or fewer years of formal education (total
#' capped at 30); apply that adjustment to the `orientation` item (or the total)
#' before or after scoring as appropriate for your protocol.
#'
#' @param items Named numeric responses giving the points earned on each domain
#'   (e.g. `delayed_recall = 3`, `orientation = 6`), or an unnamed vector in the
#'   instrument's item order.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-30) and the impairment stratum
#'   (normal / mild / moderate-severe impairment).
#' @seealso [scoreMMSE()], [getInstrument()]
#' @export
#' @examples
#' scoreMoCA(stats::setNames(c(5, 3, 6, 3, 2, 5, 6),
#'                           getInstrument("moca")@items))
scoreMoCA <- function(items, ...) scoreInstrument("moca", items, ...)
