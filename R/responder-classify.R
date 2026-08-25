.RESPONDER_LEVELS <- c("true_responder", "subclinical_change",
                       "measurement_error", "non_responder")

# Resolve an MDC/MCID threshold from the clinimetric store when not supplied.
.responder_threshold <- function(instrument, statistics, population, what) {
  for (st in statistics) {
    r <- suppressWarnings(getClinimetric(instrument, st, population))
    if (inherits(r, "clinimetric")) {
      if (nrow(r) > 1L) {
        stop(sprintf("multiple %s rows for '%s'; specify a population.",
                     what, instrument), call. = FALSE)
      }
      return(as.numeric(r$value[1L]))
    }
  }
  stop(sprintf("no %s for instrument '%s'%s; pass %s explicitly.", what,
               instrument,
               if (!is.null(population)) sprintf(" (population '%s')", population)
               else "", what), call. = FALSE)
}

#' Dual MDC-vs-MCID responder classification
#'
#' Classifies each subject's pre-to-post change with the two-criterion responder
#' framework (Beaton 2001; de Vet 2006): a change is cross-tabulated on whether
#' it exceeds the Minimal Detectable Change (is it real, above measurement
#' error?) and the Minimal Clinically Important Difference (is it clinically
#' meaningful?), giving four categories — \code{true_responder} (exceeds both),
#' \code{subclinical_change} (real but below MCID), \code{measurement_error}
#' (claims MCID but within noise, only when MCID < MDC) and
#' \code{non_responder}. Vectorized over subjects and direction-aware.
#'
#' @param baseline,followup Numeric vectors of pre / post scores (one per
#'   subject).
#' @param instrument,population Optional instrument / population used to look up
#'   \code{mdc}/\code{mcid} from the clinimetric store when they are not given.
#' @param mdc,mcid Optional explicit MDC / MCID thresholds (positive); override
#'   the store lookup.
#' @param direction \code{"increase"} (default) if higher is better, or
#'   \code{"decrease"} if lower is better.
#' @return A \code{"responder_classification"} \code{data.frame} with the change,
#'   the direction-aware improvement, the MDC/MCID crossing flags and the
#'   four-level \code{classification} factor. A subject with a missing
#'   \code{baseline}/\code{followup} gets \code{NA} flags and classification
#'   (missing, not assumed a non-responder); \code{summary()} counts it.
#' @references Beaton DE et al. (2001); de Vet HCW et al. (2006).
#' @seealso [estimateMDC()], [getClinimetric()], [mdcResponder()]
#' @examples
#' classifyResponder(c(20, 25, 30), c(31, 26, 45), mdc = 5.2, mcid = 9)
#' @export
classifyResponder <- function(baseline, followup, instrument = NULL,
                              population = NULL, mdc = NULL, mcid = NULL,
                              direction = c("increase", "decrease")) {
  direction <- match.arg(direction)
  baseline <- as.numeric(baseline)
  followup <- as.numeric(followup)
  if (length(baseline) != length(followup)) {
    stop("'baseline' and 'followup' must have the same length.", call. = FALSE)
  }
  if (is.null(mdc)) {
    if (is.null(instrument)) {
      stop("provide 'mdc' or an 'instrument' to look it up.", call. = FALSE)
    }
    mdc <- .responder_threshold(instrument, "MDC", population, "MDC")
  }
  if (is.null(mcid)) {
    if (is.null(instrument)) {
      stop("provide 'mcid' or an 'instrument' to look it up.", call. = FALSE)
    }
    mcid <- .responder_threshold(instrument, c("MCID_anchor", "MCID_dist"),
                                 population, "MCID")
  }
  if (!is.finite(mdc) || mdc <= 0 || !is.finite(mcid) || mcid <= 0) {
    stop("'mdc' and 'mcid' must be finite and positive.", call. = FALSE)
  }

  change <- followup - baseline
  improvement <- if (direction == "increase") change else -change
  exceeds_mdc <- improvement >= mdc
  exceeds_mcid <- improvement >= mcid
  cls <- ifelse(exceeds_mdc & exceeds_mcid, "true_responder",
         ifelse(exceeds_mdc & !exceeds_mcid, "subclinical_change",
         ifelse(!exceeds_mdc & exceeds_mcid, "measurement_error",
                "non_responder")))

  out <- data.frame(
    baseline = baseline, followup = followup, change = change,
    improvement = improvement, mdc = mdc, mcid = mcid,
    exceeds_mdc = exceeds_mdc, exceeds_mcid = exceeds_mcid,
    classification = factor(cls, levels = .RESPONDER_LEVELS),
    stringsAsFactors = FALSE)
  attr(out, "direction") <- direction
  class(out) <- c("responder_classification", "data.frame")
  out
}

#' @rdname classifyResponder
#' @param object A \code{"responder_classification"}.
#' @param ... Unused.
#' @return \code{summary} returns the MDC x MCID contingency table.
#' @export
summary.responder_classification <- function(object, ...) {
  # useNA so missing (dropout) subjects are counted; the table then sums to N
  table(`exceeds_MDC` = object$exceeds_mdc,
        `exceeds_MCID` = object$exceeds_mcid, useNA = "ifany")
}

#' @export
print.responder_classification <- function(x, ...) {
  cat(sprintf("<responder_classification> %d subject(s), direction: %s\n",
              nrow(x), attr(x, "direction")))
  cat(sprintf("  MDC = %s, MCID = %s\n", format(x$mdc[1L]), format(x$mcid[1L])))
  print(table(x$classification, useNA = "ifany"))
  invisible(x)
}
