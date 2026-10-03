# Typed convenience wrappers for the bundled mobility / function instruments,
# each delegating to scoreInstrument() on the corresponding bundled YAML spec.

#' Score the Fugl-Meyer Assessment, Lower Extremity (FMA-LE)
#'
#' @param items Named numeric responses (0-2 per item) for the 17 FMA-LE motor
#'   items, or an unnamed vector in the instrument's item order.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-34) and the motor and
#'   coordination/speed subscale scores.
#' @seealso [scoreBerg()], [scoreFIM()]
#' @export
#' @examples
#' scoreFMALE(stats::setNames(rep(2, 17), getInstrument("fma_le")@items))
scoreFMALE <- function(items, ...) scoreInstrument("fma_le", items, ...)

#' Score the Berg Balance Scale (BBS)
#'
#' @param items Named numeric responses (0-4 per item) for the 14 Berg items.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-56) and the fall-risk stratum.
#' @seealso [scoreFMALE()]
#' @export
scoreBerg <- function(items, ...) scoreInstrument("berg", items, ...)

#' Score the Functional Independence Measure (FIM)
#'
#' @param items Named numeric responses (1-7 per item) for the 18 FIM items.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (18-126) and subscale scores for the
#'   six FIM domains (self-care, sphincter, transfers, locomotion,
#'   communication, social cognition) plus the combined `motor` (13 items) and
#'   `cognitive` (5 items) scores.
#' @seealso [scoreFAM()]
#' @export
#' @examples
#' scoreFIM(stats::setNames(rep(4, 18), getInstrument("fim")@items))
scoreFIM <- function(items, ...) scoreInstrument("fim", items, ...)

#' Score the Functional Assessment Measure (FIM+FAM)
#'
#' @param items Named numeric responses (1-7 per item) for the 30 FIM+FAM items.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (30-210) and the combined `motor`
#'   (16 items) and `cognitive` (14 items) subscale scores.
#' @seealso [scoreFIM()]
#' @export
scoreFAM <- function(items, ...) scoreInstrument("fam", items, ...)
