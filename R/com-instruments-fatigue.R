# Typed convenience wrappers for the bundled fatigue instruments, each
# delegating to scoreInstrument() on the corresponding bundled YAML spec.
#
# The Fatigue Severity Scale (9 items, mean 1-7) and the Modified Fatigue Impact
# Scale (21 items, sum 0-84 with physical / cognitive / psychosocial subscales)
# are the standard patient-reported fatigue measures in neurorehabilitation.
# Both are directed higher_worse (a higher score is more fatigue).

#' Score the Fatigue Severity Scale (FSS)
#'
#' Averages the nine FSS statements (each rated 1 = strongly disagree to 7 =
#' strongly agree) to a mean of 1-7. A mean of 4 or more indicates clinically
#' significant fatigue.
#'
#' @param items Named numeric responses (`item1` .. `item9`) or an unnamed
#'   vector in the instrument's item order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing = "prorate"`).
#' @return A [ClinicalScore] with the mean (1-7) and the fatigue stratum.
#' @seealso [scoreMFIS()]
#' @export
#' @examples
#' scoreFSS(stats::setNames(c(6, 6, 5, 6, 5, 6, 6, 5, 6),
#'                          getInstrument("fss")@items))
scoreFSS <- function(items, ...) scoreInstrument("fss", items, ...)

#' Score the Modified Fatigue Impact Scale (MFIS)
#'
#' Sums the twenty-one MFIS items (each 0-4) to a total of 0-84 with physical
#' (9-item), cognitive (10-item) and psychosocial (2-item) subscales. A total of
#' 38 or more indicates fatigue.
#'
#' @param items Named numeric responses (`item01` .. `item21`) or an unnamed
#'   vector in the instrument's item order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing = "prorate"`).
#' @return A [ClinicalScore] with the total (0-84), the three subscale scores and
#'   the fatigue stratum.
#' @seealso [scoreFSS()], [getInstrument()]
#' @export
#' @examples
#' scoreMFIS(stats::setNames(rep(2, 21), getInstrument("mfis")@items))
scoreMFIS <- function(items, ...) scoreInstrument("mfis", items, ...)
