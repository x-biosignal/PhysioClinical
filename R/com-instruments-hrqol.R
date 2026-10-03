# Typed convenience wrapper for the bundled health-related quality-of-life
# instrument, delegating to scoreInstrument() on the bundled YAML spec.
#
# The EQ-5D-5L descriptive system rates five dimensions (mobility, self-care,
# usual activities, pain/discomfort, anxiety/depression) on five levels each.
# Here it is scored as a level-sum score (5-25, higher = worse); the
# country-specific utility index and the EQ-VAS are recorded separately and are
# out of scope for this ordinal scorer.

#' Score the EQ-5D-5L descriptive system (level-sum score)
#'
#' Sums the five EQ-5D-5L dimension levels (1 = no problems to 5 =
#' extreme problems / unable) to a level-sum score of 5-25, higher indicating
#' worse health. The utility index requires a country-specific value set and is
#' not computed here; the EQ-VAS (0-100) is a separate rating.
#'
#' @param items Named numeric levels (e.g. `mobility = 2`, `pain_discomfort = 3`)
#'   or an unnamed vector in the instrument's item order (mobility, self-care,
#'   usual activities, pain/discomfort, anxiety/depression).
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the level-sum score (5-25).
#' @seealso [getInstrument()]
#' @export
#' @examples
#' scoreEQ5D5L(c(mobility = 2, self_care = 1, usual_activities = 2,
#'               pain_discomfort = 3, anxiety_depression = 2))
scoreEQ5D5L <- function(items, ...) scoreInstrument("eq5d5l", items, ...)

#' Score the SF-36 / RAND-36 Health Survey
#'
#' Scores the RAND 36-Item Health Survey 1.0: each item's raw response is recoded
#' to 0-100 (via the instrument's `item_recode` map) and averaged within its
#' scale, giving the eight subscale scores (0-100, higher = better health) in the
#' returned `subscales`: physical functioning, role-physical, role-emotional,
#' energy/fatigue, emotional well-being, social functioning, pain and general
#' health. The health-transition item is not part of the eight scales. The
#' norm-based T-scores and the PCS/MCS component summaries use proprietary
#' population weights and are out of scope.
#'
#' @param items Named numeric raw responses on the questionnaire's own answer
#'   scales (`q01`, `q03`..`q36`, omitting the health-transition item `q02`), or
#'   an unnamed vector in the instrument's item order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing = "prorate"` to score
#'   a scale from its completed items).
#' @return A [ClinicalScore] whose `subscales` hold the eight 0-100 scale scores
#'   (the `total` is the grand mean over all items, not a standard SF-36 score).
#' @seealso [scoreEQ5D5L()], [getInstrument()]
#' @references Hays RD, Sherbourne CD, Mazel RM (1993). The RAND 36-Item Health
#'   Survey 1.0. *Health Econ* 2:217-227.
#' @export
#' @examples
#' # all best-health responses -> every subscale scores 100
#' best <- stats::setNames(
#'   c(1, rep(3, 10), rep(2, 7), 1, 1, 1, 1, 6, 6, 1, 1, 6, 6, 1, 6, 5, 5, 1, 5, 1),
#'   getInstrument("sf36")@items)
#' scoreSF36(best)@subscales
scoreSF36 <- function(items, ...) scoreInstrument("sf36", items, ...)
