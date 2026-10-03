# Typed convenience wrappers for the bundled stroke / upper-limb instruments.
# Each delegates to scoreInstrument() on the corresponding bundled YAML spec,
# adding the scale-specific response handling (notably the Modified Ashworth
# "1+" level, which is 1.5 for arithmetic but retains its label).

#' Score the Fugl-Meyer Assessment, Upper Extremity (FMA-UE)
#'
#' @param items Named numeric responses (0-2 per item) for the 33 FMA-UE motor
#'   items, or an unnamed vector in the instrument's item order.
#' @param ... Passed to [scoreInstrument()] (e.g. `missing`, `subject_id`).
#' @return A [ClinicalScore] with the total (0-66), the four subscale scores
#'   (shoulder/elbow/forearm, wrist, hand, coordination/speed) and the
#'   severe/moderate/mild stratum (Woodbury 2013).
#' @seealso [scoreARAT()], [scoreInstrument()]
#' @export
#' @examples
#' scoreFMAUE(stats::setNames(rep(2, 33), getInstrument("fma_ue")@items))
scoreFMAUE <- function(items, ...) scoreInstrument("fma_ue", items, ...)

#' Score the Action Research Arm Test (ARAT)
#'
#' @param items Named numeric responses (0-3 per item) for the 19 ARAT items.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-57) and the grasp/grip/pinch/
#'   gross-movement subscale scores.
#' @seealso [scoreFMAUE()]
#' @export
scoreARAT <- function(items, ...) scoreInstrument("arat", items, ...)

#' Score the NIH Stroke Scale (NIHSS)
#'
#' @param items Named numeric responses for the 15 NIHSS components (each within
#'   its own range).
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] with the total (0-42) and the severity band
#'   (no stroke / minor / moderate / moderate-to-severe / severe).
#' @seealso [scoreMRS()]
#' @export
scoreNIHSS <- function(items, ...) scoreInstrument("nihss", items, ...)

#' Score the modified Rankin Scale (mRS)
#'
#' @param grade A single global disability grade, 0-6.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] whose total is the grade and whose stratum is the
#'   disability label.
#' @seealso [scoreNIHSS()]
#' @export
#' @examples
#' scoreMRS(3)
scoreMRS <- function(grade, ...) {
  scoreInstrument("mrs", c(grade = as.numeric(grade)[1]), ...)
}

#' Score the Wolf Motor Function Test functional-ability scale (WMFT-FAS)
#'
#' @param fas Named numeric responses (0-5 per task) for the 15 functional
#'   tasks.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] whose total is the mean functional-ability score.
#' @seealso [wmftMedianTime()]
#' @export
scoreWMFT <- function(fas, ...) scoreInstrument("wmft_fas", fas, ...)

#' Median WMFT performance time
#'
#' Summarises the Wolf Motor Function Test timed-task performance as the median
#' time across tasks, the conventional WMFT time summary.
#'
#' @param times Numeric vector of per-task performance times (seconds).
#' @return The median time (seconds).
#' @seealso [scoreWMFT()]
#' @export
wmftMedianTime <- function(times) stats::median(as.numeric(times), na.rm = TRUE)

# --- Modified Ashworth Scale label handling -------------------------------

# The MAS ordinal levels and their arithmetic values; "1+" sits between 1 and 2.
.MAS_LEVELS <- c("0" = 0, "1" = 1, "1+" = 1.5, "2" = 2, "3" = 3, "4" = 4)

# Map a MAS response (a level label such as "1+", or a number) to its value.
.mas_to_numeric <- function(x) {
  vapply(x, function(v) {
    key <- trimws(as.character(v))
    if (key %in% names(.MAS_LEVELS)) {
      unname(.MAS_LEVELS[[key]])
    } else {
      num <- suppressWarnings(as.numeric(key))
      if (is.na(num) || !num %in% .MAS_LEVELS) {
        stop(sprintf("Invalid MAS level '%s'; expected one of %s.", v,
                     paste(names(.MAS_LEVELS), collapse = ", ")), call. = FALSE)
      }
      num
    }
  }, numeric(1))
}

#' Modified Ashworth Scale level label for a value
#'
#' The inverse of the MAS arithmetic mapping: returns the ordinal label for a
#' numeric MAS value (so `1.5` round-trips to `"1+"`).
#'
#' @param value Numeric MAS value(s).
#' @return Character MAS level label(s).
#' @seealso [scoreMAS()]
#' @export
#' @examples
#' masLevelLabel(1.5)
masLevelLabel <- function(value) {
  vapply(as.numeric(value), function(v) {
    hit <- names(.MAS_LEVELS)[which(abs(.MAS_LEVELS - v) < 1e-9)]
    if (length(hit)) hit[1] else NA_character_
  }, character(1))
}

#' Score a Modified Ashworth Scale (MAS) rating
#'
#' Accepts a MAS rating as its ordinal level label (`"0"`, `"1"`, `"1+"`, `"2"`,
#' `"3"`, `"4"`) or the equivalent number, mapping `"1+"` to 1.5 for arithmetic
#' while preserving the label. Rate one muscle group per call.
#'
#' @param rating A single MAS level label or number.
#' @param ... Passed to [scoreInstrument()].
#' @return A [ClinicalScore] whose total is the numeric MAS value; the ordinal
#'   label is recovered with [masLevelLabel()].
#' @seealso [masLevelLabel()]
#' @export
#' @examples
#' scoreMAS("1+")
scoreMAS <- function(rating, ...) {
  val <- unname(.mas_to_numeric(rating[1]))
  scoreInstrument("mas", c(muscle = val), ...)
}
