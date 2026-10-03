# PROMIS scoring: graded response model (GRM) EAP theta / T-score estimation.
#
# PROMIS measures are IRT-calibrated: an item's responses relate to the latent
# trait through Samejima's graded response model, and the person score is
# reported on the T-score metric (mean 50, SD 10 in the US general population).
# This module implements the standard GRM EAP scoring and a summed-score ->
# T-score lookup. It ships NO item calibrations: the official item parameters
# (slopes + thresholds) and the short-form raw-to-T-score tables are published by
# HealthMeasures (www.healthmeasures.net) and must be supplied by the caller, so
# no calibration is fabricated here.

# GRM category probabilities P(Y = k | theta) for a single K-category item with
# slope `a` and ordered thresholds `b` (length K - 1). Returns a
# length(theta) x K matrix.
.grm_prob <- function(theta, a, b) {
  K <- length(b) + 1L
  # cumulative boundaries P(Y >= j): column 1 = 1, column K+1 = 0
  pstar <- matrix(0, nrow = length(theta), ncol = K + 1L)
  pstar[, 1L] <- 1
  for (k in seq_len(K - 1L)) pstar[, k + 1L] <- stats::plogis(a * (theta - b[k]))
  p <- pstar[, seq_len(K), drop = FALSE] -
       pstar[, seq_len(K) + 1L, drop = FALSE]
  p[p < 1e-12] <- 1e-12
  p
}

#' Score a PROMIS (or other GRM) short form by EAP
#'
#' Estimates the latent trait for a set of item responses under Samejima's graded
#' response model by expected a posteriori (EAP) scoring over a normal
#' quadrature, and reports it on the PROMIS T-score metric (mean 50, SD 10).
#'
#' No item parameters are bundled: supply the official PROMIS calibration
#' (slopes and thresholds) from HealthMeasures. Any GRM-scored instrument works
#' with the same function.
#'
#' @param responses Named numeric vector of item responses (category 1..K per
#'   item; `NA` for a skipped item), or a one-row data.frame. Names must match
#'   `calibration$item`; an unnamed vector is taken in `calibration` row order.
#' @param calibration A data.frame with columns `item`, `a` (slope) and ordered
#'   threshold columns `b1`, `b2`, ... (a K-category item uses K-1 thresholds;
#'   pad shorter items with `NA`).
#' @param quad_points,quad_range EAP quadrature: number of nodes and half-width
#'   (nodes span `[-quad_range, quad_range]`; defaults 61 and 4).
#' @param prior_mean,prior_sd Normal prior on the latent trait (default standard
#'   normal, the PROMIS calibration metric).
#' @return A list with `theta`, `se_theta`, `tscore` (`50 + 10 * theta`),
#'   `se_tscore` and `n_items` (items actually scored).
#' @references Samejima F (1969). Estimation of latent ability using a response
#'   pattern of graded scores. *Psychometrika Monograph* 17. PROMIS scoring:
#'   HealthMeasures, www.healthmeasures.net.
#' @seealso [promisRawToT()]
#' @export
#' @examples
#' # illustrative calibration (NOT official PROMIS parameters)
#' cal <- data.frame(item = c("i1", "i2", "i3"), a = c(2.4, 1.9, 2.7),
#'   b1 = c(-2, -1.5, -1.8), b2 = c(-1, -0.5, -0.7),
#'   b3 = c(0.2, 0.1, 0), b4 = c(1.4, 1.2, 1.1))
#' scorePROMIS(c(i1 = 4, i2 = 5, i3 = 4), cal)
scorePROMIS <- function(responses, calibration, quad_points = 61,
                        quad_range = 4, prior_mean = 0, prior_sd = 1) {
  if (is.data.frame(responses)) {
    responses <- stats::setNames(as.numeric(unlist(responses[1, ])),
                                 names(responses))
  }
  resp <- as.numeric(responses)
  names(resp) <- names(responses)
  if (!is.data.frame(calibration) || !all(c("item", "a") %in% names(calibration))) {
    stop("'calibration' must be a data.frame with 'item', 'a' and b1.. columns.",
         call. = FALSE)
  }
  if (is.null(names(resp))) {
    if (nrow(calibration) != length(resp)) {
      stop("an unnamed 'responses' must have one value per calibration row.",
           call. = FALSE)
    }
    names(resp) <- as.character(calibration$item)
  }
  bcols <- grep("^b[0-9]+$", names(calibration), value = TRUE)
  bcols <- bcols[order(as.integer(sub("^b", "", bcols)))]
  if (!length(bcols)) stop("'calibration' has no threshold columns b1, b2, ...",
                           call. = FALSE)

  theta <- seq(-quad_range, quad_range, length.out = quad_points)
  logpost <- stats::dnorm(theta, prior_mean, prior_sd, log = TRUE)
  used <- 0L
  for (it in names(resp)) {
    y <- resp[[it]]
    if (is.na(y)) next
    row <- calibration[as.character(calibration$item) == it, , drop = FALSE]
    if (nrow(row) != 1L) {
      stop(sprintf("'calibration' must have exactly one row for item '%s'.", it),
           call. = FALSE)
    }
    b <- as.numeric(unlist(row[1, bcols])); b <- sort(b[!is.na(b)])
    K <- length(b) + 1L
    if (y != round(y) || y < 1 || y > K) {
      stop(sprintf("item '%s' response %s is outside 1..%d.", it, y, K),
           call. = FALSE)
    }
    p <- .grm_prob(theta, as.numeric(row$a[1]), b)
    logpost <- logpost + log(p[, y])
    used <- used + 1L
  }
  if (used == 0L) stop("no non-missing responses to score.", call. = FALSE)
  w <- exp(logpost - max(logpost)); w <- w / sum(w)
  eap <- sum(theta * w)
  se <- sqrt(sum((theta - eap)^2 * w))
  list(theta = eap, se_theta = se, tscore = 50 + 10 * eap,
       se_tscore = 10 * se, n_items = used)
}

#' Convert a PROMIS summed score to a T-score via a lookup table
#'
#' The other official PROMIS scoring path for a full short form: map the summed
#' raw score to a T-score with the instrument's published summed-score-to-T-score
#' table. The table is not bundled - obtain it from the HealthMeasures scoring
#' manual for the specific short form.
#'
#' @param raw Summed raw score.
#' @param conversion_table A data.frame with a `raw` column, a `tscore` column
#'   and optionally an `se` column (the published conversion table).
#' @return A list with `tscore` and `se` (`NA` if the table has no `se` column);
#'   `NA` with a warning if `raw` is not in the table.
#' @seealso [scorePROMIS()]
#' @export
#' @examples
#' tab <- data.frame(raw = 4:8, tscore = c(21.5, 30.1, 35.7, 40.2, 44.0))
#' promisRawToT(6, tab)
promisRawToT <- function(raw, conversion_table) {
  if (!is.data.frame(conversion_table) ||
      !all(c("raw", "tscore") %in% names(conversion_table))) {
    stop("'conversion_table' must be a data.frame with 'raw' and 'tscore'.",
         call. = FALSE)
  }
  row <- conversion_table[conversion_table$raw == raw, , drop = FALSE]
  if (nrow(row) == 0L) {
    warning(sprintf("raw score %s is not in the conversion table.", raw),
            call. = FALSE)
    return(list(tscore = NA_real_, se = NA_real_))
  }
  list(tscore = as.numeric(row$tscore[1]),
       se = if ("se" %in% names(row)) as.numeric(row$se[1]) else NA_real_)
}
