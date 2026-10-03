# Score crosswalks (equating) between clinical scales.
#
# Different services record different ADL instruments -- one ward uses the
# Barthel Index, the next the FIM -- yet a study, registry or care transfer needs
# them on one scale. Equating builds that crosswalk from a linking sample in
# which the same people (or equivalent groups) were measured on both scales,
# without assuming the scales are linearly related. This is the standard basis
# of the published Barthel<->FIM conversions (e.g. Houlden et al. 2006).

# mid-percentile rank of each value within a reference distribution (0-100).
.percentile_rank <- function(value, ref) {
  n <- length(ref)
  vapply(value, function(v)
    (sum(ref < v) + 0.5 * sum(ref == v)) / n * 100, numeric(1))
}

#' Equate one clinical score scale to another (build a crosswalk)
#'
#' Constructs a conversion from a "source" scale to a "target" scale using a
#' linking sample measured on both. Equipercentile equating (the default) maps a
#' source score to the target score with the same percentile rank, so it handles
#' the non-linear, bounded relationship typical of ADL scales; linear equating
#' matches only the mean and SD.
#'
#' @param from Numeric source-scale scores from the linking sample.
#' @param to Numeric target-scale scores from the linking sample (equipercentile
#'   uses the two marginal distributions; linear uses their means and SDs).
#' @param method `"equipercentile"` (default) or `"linear"`.
#' @param from_scores Source scores to tabulate (default: the sorted unique
#'   observed source scores).
#' @return an object of class `score_equating`: a list with `table`
#'   (data.frame `from`, `to`), `method`, and the linking-sample size. Convert
#'   new values with [applyEquating()].
#' @references Kolen MJ, Brennan RL (2004) Test Equating, Scaling, and Linking;
#'   Houlden H et al. (2006) Clin Rehabil 20:153-159 (Barthel<->FIM).
#' @seealso [applyEquating()]
#' @export
#' @examples
#' set.seed(1)
#' ability <- rnorm(200)
#' barthel <- pmin(100, pmax(0, round((ability + 3) * 16 / 5) * 5))
#' fim <- pmin(126, pmax(18, round(18 + (ability + 3) * 18)))
#' eq <- equateScores(barthel, fim)          # Barthel -> FIM crosswalk
#' head(eq$table)
equateScores <- function(from, to, method = c("equipercentile", "linear"),
                         from_scores = sort(unique(from[is.finite(from)]))) {
  method <- match.arg(method)
  from <- from[is.finite(from)]; to <- to[is.finite(to)]
  if (length(from) < 2L || length(to) < 2L) {
    stop("need at least two finite scores in each scale.", call. = FALSE)
  }
  to_equiv <- if (method == "equipercentile") {
    pr <- .percentile_rank(from_scores, from)
    stats::quantile(to, probs = pr / 100, names = FALSE, type = 7)
  } else {
    slope <- stats::sd(to) / stats::sd(from)
    mean(to) + slope * (from_scores - mean(from))
  }
  structure(list(table = data.frame(from = from_scores, to = to_equiv),
                 method = method, n = length(from)),
            class = "score_equating")
}

#' Apply a score crosswalk to new values
#'
#' @param equating a `score_equating` from [equateScores()].
#' @param values numeric source-scale values to convert.
#' @return numeric target-scale equivalents (linearly interpolated within the
#'   crosswalk, clamped to its range).
#' @seealso [equateScores()]
#' @export
#' @examples
#' set.seed(1)
#' ability <- rnorm(200)
#' barthel <- pmin(100, pmax(0, round((ability + 3) * 16 / 5) * 5))
#' fim <- pmin(126, pmax(18, round(18 + (ability + 3) * 18)))
#' applyEquating(equateScores(barthel, fim), c(40, 60, 80))
applyEquating <- function(equating, values) {
  stopifnot(inherits(equating, "score_equating"))
  tb <- equating$table
  stats::approx(tb$from, tb$to, xout = values, rule = 2)$y
}

#' @export
print.score_equating <- function(x, ...) {
  cat(sprintf("<score_equating> %s | linking n=%d | %d source scores\n",
              x$method, x$n, nrow(x$table)))
  cat(sprintf("  range: %g -> %.1f  ..  %g -> %.1f\n",
              x$table$from[1], x$table$to[1],
              x$table$from[nrow(x$table)], x$table$to[nrow(x$table)]))
  invisible(x)
}
