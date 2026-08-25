#' Classify change scores against the minimal detectable change (MDC)
#'
#' A first responder-analysis primitive: a change is a real improvement/decline
#' only if it exceeds the MDC (measurement noise). Uses \code{PhysioCore::mdc}.
#'
#' @param change Numeric change score(s) (follow-up minus baseline).
#' @param sem_value The standard error of measurement (see \code{PhysioCore::sem}).
#' @param confidence Confidence level for the MDC (default 0.95).
#' @return Character vector: \code{"improved"}, \code{"stable"}, or \code{"declined"}.
#' @examples
#' mdcResponder(c(5, 0.5, -6), sem_value = 1.5)
#' @export
mdcResponder <- function(change, sem_value, confidence = 0.95) {
  threshold <- PhysioCore::mdc(sem_value, confidence)
  out <- rep("stable", length(change))
  out[change >=  threshold] <- "improved"
  out[change <= -threshold] <- "declined"
  out
}
