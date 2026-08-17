# Estimation of clinimetric change thresholds (MDC / MCID) from data.

.as_retest_matrix <- function(test_retest) {
  if (is.data.frame(test_retest)) test_retest <- as.matrix(test_retest)
  if (!is.matrix(test_retest) || ncol(test_retest) < 2L) {
    stop("'test_retest' must be a subjects-by-occasions matrix (>= 2 columns).",
         call. = FALSE)
  }
  if (!is.numeric(test_retest) || any(!is.finite(test_retest))) {
    stop("'test_retest' must be finite and numeric.", call. = FALSE)
  }
  test_retest
}

#' Distribution-based Minimal Detectable Change from test-retest data
#'
#' Estimates the MDC from a test-retest reliability study: the intraclass
#' correlation gives the reliability, the standard error of measurement is
#' \eqn{SD\sqrt{1 - ICC}}, and \eqn{MDC = SEM \times z \times \sqrt{2}}
#' (delegating to \code{PhysioCore::icc}/\code{sem}/\code{mdc}).
#'
#' @param test_retest A subjects-by-occasions numeric matrix (or data.frame) of
#'   repeated measurements.
#' @param method Estimation method; currently \code{"distribution"}.
#' @param confidence Confidence level for the MDC (default 0.95).
#' @param model ICC model passed to \code{PhysioCore::icc} (default
#'   \code{"twoway"}).
#' @return A list with \code{mdc}, \code{sem}, \code{icc} and \code{confidence}.
#' @references Shrout & Fleiss (1979); de Vet et al. (2006).
#' @seealso [estimateMCID_distribution()], [estimateMCID_anchor()]
#' @examples
#' set.seed(1)
#' base <- rnorm(40, 50, 10)
#' retest <- base + rnorm(40, 0, 3)
#' estimateMDC(cbind(base, retest))
#' @export
estimateMDC <- function(test_retest, method = "distribution",
                        confidence = 0.95, model = c("twoway", "oneway")) {
  method <- match.arg(method, "distribution")
  model <- match.arg(model)
  m <- .as_retest_matrix(test_retest)
  icc_val <- PhysioCore::icc(m, model = model)$icc
  # a negative ICC (reliability worse than chance) has no clinimetric meaning for
  # SEM; clamp to 0 (maximal SEM) rather than let PhysioCore::sem reject r < 0
  if (is.finite(icc_val) && icc_val < 0) {
    warning("ICC < 0 (unreliable); clamping reliability to 0 for the SEM.",
            call. = FALSE)
    icc_val <- 0
  }
  sem_val <- PhysioCore::sem(as.numeric(m), icc_value = icc_val)
  list(mdc = PhysioCore::mdc(sem_val, confidence), sem = sem_val,
       icc = icc_val, confidence = confidence)
}

#' Distribution-based MCID (fraction-of-SD rule)
#'
#' The distribution-based Minimal Clinically Important Difference as a fraction
#' of the baseline standard deviation (Norman et al. 2003: the 0.5 SD rule).
#'
#' @param baseline_sd Baseline standard deviation of the outcome.
#' @param fraction Fraction of the SD (default 0.5).
#' @return The MCID estimate (\code{fraction * baseline_sd}).
#' @references Norman GR, Sloan JA, Wyrwich KW (2003). \emph{Med Care} 41(5).
#' @seealso [estimateMDC()], [estimateMCID_anchor()]
#' @examples
#' estimateMCID_distribution(baseline_sd = 12)
#' @export
estimateMCID_distribution <- function(baseline_sd, fraction = 0.5) {
  if (!is.numeric(baseline_sd) || length(baseline_sd) != 1L ||
      !is.finite(baseline_sd) || baseline_sd < 0) {
    stop("'baseline_sd' must be a single non-negative number.", call. = FALSE)
  }
  if (!is.numeric(fraction) || length(fraction) != 1L || fraction <= 0) {
    stop("'fraction' must be a positive number.", call. = FALSE)
  }
  fraction * baseline_sd
}

# Youden-optimal cut of `score` for a binary `label` (1 = positive), higher
# score = more positive.
.roc_youden_cut <- function(score, label) {
  ord <- sort(unique(score))
  cand <- c(min(score) - 1, (ord[-length(ord)] + ord[-1]) / 2, max(score) + 1)
  npos <- sum(label == 1L)
  nneg <- sum(label == 0L)
  if (npos == 0L || nneg == 0L) {
    stop("the anchor must contain both improved and non-improved cases.",
         call. = FALSE)
  }
  j <- vapply(cand, function(t) {
    pred <- score >= t
    sum(pred & label == 1L) / npos + sum(!pred & label == 0L) / nneg - 1
  }, numeric(1))
  cand[which.max(j)]
}

#' Anchor-based MCID
#'
#' Estimates the MCID from change scores anchored to an external improvement
#' indicator. \code{"roc"} returns the change cut-off that maximizes the Youden
#' index for classifying the anchor; \code{"mean_change"} the mean change among
#' the (minimally) improved; \code{"predictive"} the change at which a logistic
#' model of the anchor crosses probability 0.5.
#'
#' @param change Numeric change scores (follow-up minus baseline).
#' @param anchor Improvement indicator aligned to \code{change}: logical, or 0/1,
#'   where TRUE/1 marks an (minimally) improved case.
#' @param method \code{"roc"} (default), \code{"mean_change"} or
#'   \code{"predictive"}.
#' @param direction \code{"increase"} (default) if a higher change means
#'   improvement, or \code{"decrease"} if a lower change does.
#' @return The MCID estimate (on the change scale).
#' @references Jaeschke et al. (1989); Copay et al. (2007).
#' @seealso [estimateMDC()], [estimateMCID_distribution()]
#' @examples
#' set.seed(1)
#' change <- c(rnorm(50, 1, 2), rnorm(50, 8, 2))
#' anchor <- rep(c(0, 1), each = 50)
#' estimateMCID_anchor(change, anchor)
#' @importFrom stats binomial glm predict
#' @export
estimateMCID_anchor <- function(change, anchor,
                                method = c("roc", "mean_change", "predictive"),
                                direction = c("increase", "decrease")) {
  method <- match.arg(method)
  direction <- match.arg(direction)
  change <- as.numeric(change)
  label <- as.integer(as.logical(anchor))
  if (length(change) != length(label)) {
    stop("'change' and 'anchor' must have the same length.", call. = FALSE)
  }
  if (anyNA(change) || anyNA(label)) {
    stop("'change' and 'anchor' must not contain NA.", call. = FALSE)
  }
  score <- if (direction == "increase") change else -change

  est <- switch(method,
    roc = .roc_youden_cut(score, label),
    mean_change = mean(change[label == 1L]),
    predictive = {
      # well-separated anchor groups make glm warn about perfect separation; the
      # p = 0.5 crossing is still the intended cut, so quiet the fit warnings
      fit <- suppressWarnings(
        stats::glm(label ~ score, family = stats::binomial()))
      co <- stats::coef(fit)
      if (!is.finite(co[[2L]]) || co[[2L]] == 0) {
        stop("the predictive model has no usable change-probability slope.",
             call. = FALSE)
      }
      -co[[1L]] / co[[2L]]   # score where the linear predictor is 0 (p = 0.5)
    })
  # map back to the change scale for the ROC / predictive (score) methods
  if (method %in% c("roc", "predictive") && direction == "decrease") {
    est <- -est
  }
  est
}
