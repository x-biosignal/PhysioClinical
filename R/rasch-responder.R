# Responder analysis on the interval (Rasch) scale.
#
# The reason to Rasch-score an ADL/IADL scale is that change then means the same
# thing everywhere on the scale -- unlike a raw sum, where a 5-point gain near
# the floor and near the ceiling are not equal. This wires the interval person
# measures from raschAnalyze() into the existing responder machinery: the Rasch
# model supplies a distribution-free standard error of measurement (each person's
# own SE), from which the Minimal Detectable Change follows, and the pre/post
# logit change drives mdcResponder() (reliable change) and classifyResponder()
# (the MDC x MCID four-way framework) on a properly linear scale.

.rasch_measures <- function(fit) {
  if (inherits(fit, "poly_rasch")) return(list(theta = fit$theta, se = fit$theta_se))
  if (is.list(fit) && !is.null(fit$theta)) {
    return(list(theta = as.numeric(fit$theta),
                se = as.numeric(fit$theta_se %||% fit$se)))
  }
  if (is.numeric(fit)) return(list(theta = as.numeric(fit), se = NULL))
  stop("expected a poly_rasch fit, a list with theta/theta_se, or a numeric ",
       "measure vector.", call. = FALSE)
}

#' Responder analysis of pre-to-post change on the Rasch interval scale
#'
#' Classifies each person's change between two occasions using interval (logit)
#' measures from [raschAnalyze()] / [PhysioAppKit::pcm_measure()]. The Rasch
#' model's own standard errors give a distribution-free standard error of
#' measurement and hence the Minimal Detectable Change; the pre/post change is
#' then run through [mdcResponder()] (reliable change) and, when an MCID on the
#' logit scale is supplied, [classifyResponder()] (the MDC x MCID framework).
#'
#' The two occasions must be on a common metric -- calibrate the items once and
#' anchor them, or co-calibrate -- and the persons must align by row.
#'
#' @param pre,post Baseline and follow-up measures: a `poly_rasch` fit, a list
#'   with `theta`/`theta_se`, or a numeric measure vector. `se` is required (from
#'   the fit) to derive the MDC.
#' @param mcid Optional MCID on the logit scale; enables the four-level
#'   [classifyResponder()] output.
#' @param confidence Confidence level for the MDC (default 0.95).
#' @param direction `"increase"` (default; higher measure = better) or
#'   `"decrease"`.
#' @return a `data.frame`, one row per person: `pre`, `post`, `change`,
#'   `improvement` (direction-aware), `sem`, `mdc`, `reliable_change` (from
#'   [mdcResponder()]) and, if `mcid` given, `classification` (from
#'   [classifyResponder()]). Attributes `sem`, `mdc`, `mcid` record the values used.
#' @seealso [raschAnalyze()], [mdcResponder()], [classifyResponder()],
#'   [estimateMDC()]
#' @export
#' @examples
#' pre  <- list(theta = c(0, 0, 0, 0), theta_se = rep(0.3, 4))
#' post <- list(theta = c(1.5, 0.1, -1.2, 0.05), theta_se = rep(0.3, 4))
#' raschResponder(pre, post, mcid = 1.0)
raschResponder <- function(pre, post, mcid = NULL, confidence = 0.95,
                           direction = c("increase", "decrease")) {
  direction <- match.arg(direction)
  a <- .rasch_measures(pre); b <- .rasch_measures(post)
  if (length(a$theta) != length(b$theta)) {
    stop("`pre` and `post` must cover the same persons (equal length).",
         call. = FALSE)
  }
  if (is.null(a$se) && is.null(b$se)) {
    stop("standard errors are required (use a poly_rasch fit); the MDC needs ",
         "the measurement SE.", call. = FALSE)
  }
  # model-based SEM: RMS of the person SEs across both occasions (logit scale)
  sem <- sqrt(mean(c(a$se, b$se)^2, na.rm = TRUE))
  mdc_val <- PhysioCore::mdc(sem, confidence)

  change <- b$theta - a$theta
  improvement <- if (direction == "increase") change else -change
  reliable <- mdcResponder(improvement, sem, confidence)

  out <- data.frame(pre = a$theta, post = b$theta, change = change,
                    improvement = improvement, sem = sem, mdc = mdc_val,
                    reliable_change = reliable, stringsAsFactors = FALSE)
  if (!is.null(mcid)) {
    rc <- classifyResponder(a$theta, b$theta, mdc = mdc_val, mcid = mcid,
                            direction = direction)
    out$classification <- rc$classification
  }
  attr(out, "sem") <- sem; attr(out, "mdc") <- mdc_val
  attr(out, "mcid") <- mcid; attr(out, "direction") <- direction
  out
}
