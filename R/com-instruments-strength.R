# Typed convenience wrapper for the bundled muscle-strength instrument,
# delegating to scoreInstrument() on the bundled YAML spec.
#
# The Medical Research Council (MRC) sum score aggregates manual muscle testing
# of six bilateral movements (0-5 each) into a 0-60 total that is the standard
# bedside quantification of generalised weakness (neuromuscular disease,
# ICU-acquired weakness).

#' Score the Medical Research Council (MRC) sum score
#'
#' Sums manual muscle-test grades (0 = no contraction to 5 = normal power) for
#' six movements tested bilaterally - shoulder abduction, elbow flexion, wrist
#' extension, hip flexion, knee extension and ankle dorsiflexion - to a total of
#' 0-60, higher being stronger. A total below 48 defines ICU-acquired weakness.
#'
#' @param items Named numeric grades (e.g. `elbow_flexion_r = 4`,
#'   `ankle_dorsiflexion_l = 3`) or an unnamed vector in the instrument's item
#'   order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing = "prorate"`).
#' @return A [ClinicalScore] with the total (0-60), the upper-limb / lower-limb /
#'   left / right subscale sums and the weakness stratum.
#' @seealso [getInstrument()]
#' @export
#' @examples
#' scoreMRCSum(stats::setNames(rep(5, 12), getInstrument("mrc_sum")@items))
scoreMRCSum <- function(items, ...) scoreInstrument("mrc_sum", items, ...)
