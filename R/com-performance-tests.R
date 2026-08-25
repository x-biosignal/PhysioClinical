# Clinical scoring of timed performance tests (10mWT, 6MWT, TUG). Signal-derived
# measures come from PhysioMoCap; this layer adds the clinical interpretation
# (ambulation category, Enright predicted / lower-limit-of-normal, TUG fall-risk
# cut-offs) and an optional normative z-score.

# Gait-speed ambulation category (Perry 1995; Fritz & Lusardi 2009 thresholds).
.ambulation_category <- function(speed) {
  if (speed < 0.4) "household"
  else if (speed < 0.8) "limited_community"
  else "community"
}

# Enright & Sherrill (1998) 6MWT reference equations (metres).
.enright_6mwt <- function(age, sex, height_cm, weight_kg) {
  sex <- tolower(as.character(sex))
  if (sex %in% c("m", "male")) {
    pred <- 7.57 * height_cm - 5.02 * age - 1.76 * weight_kg - 309
    lln <- pred - 153
  } else if (sex %in% c("f", "female")) {
    pred <- 2.11 * height_cm - 5.78 * age - 2.29 * weight_kg + 667
    lln <- pred - 139
  } else {
    stop("'sex' must be male/female (m/f).", call. = FALSE)
  }
  list(predicted = pred, lln = lln)
}

.perf_z <- function(value, ref, covariates) {
  if (is.null(ref)) return(NULL)
  normativeZScore(value, ref, covariates)
}

.perf_score <- function(test, measure, ...) {
  structure(c(list(test = test), measure, list(...)),
            class = "performance_test_score")
}

# Resolve a 10mWT gait speed from a speed, a time, or a PhysioMoCap result.
.resolve_walk_speed <- function(x, time_s, distance) {
  speed <- if (!is.null(x)) {
    if (inherits(x, "walk_test_report") && !is.null(x$gait_speed)) {
      as.numeric(x$gait_speed)
    } else if (inherits(x, "gait_parameters") && !is.null(x$walking_speed)) {
      mean(as.numeric(x$walking_speed), na.rm = TRUE)
    } else if (is.numeric(x) && length(x) == 1L) {
      as.numeric(x)
    } else {
      stop("unrecognized 10mWT input; pass a gait speed, a PhysioMoCap ",
           "walk_test_report or gait_parameters.", call. = FALSE)
    }
  } else if (!is.null(time_s)) {
    if (!is.finite(time_s) || time_s <= 0) {
      stop("'time_s' must be a positive number.", call. = FALSE)
    }
    distance / time_s
  } else {
    stop("provide a gait speed (x / time_s) or a PhysioMoCap walk result.",
         call. = FALSE)
  }
  # every input path resolves to one finite, positive speed (an all-NA MoCap
  # result would otherwise reach the category test as NaN and abort cryptically)
  if (!is.finite(speed) || speed <= 0) {
    stop("could not resolve a finite, positive gait speed from the 10mWT input.",
         call. = FALSE)
  }
  speed
}

#' Score a 10-metre walk test (10mWT)
#'
#' Computes comfortable/fast gait speed and its ambulation category, with an
#' optional normative z-score. Accepts a gait speed directly, a walk time, or a
#' PhysioMoCap signal-derived result (\code{walk_test_report} from
#' \code{PhysioMoCap::instrumented10mWT} or \code{gait_parameters} from
#' \code{PhysioMoCap::calculateGaitParameters}).
#'
#' @param x A gait speed (m/s), a \code{walk_test_report}, or a
#'   \code{gait_parameters}; or \code{NULL} to use \code{time_s}.
#' @param time_s Walk time in seconds (manual path; speed = \code{distance/time}).
#' @param distance Walk distance in metres (default 10).
#' @param pace \code{"comfortable"} (default) or \code{"fast"}.
#' @param ref Optional \code{\linkS4class{GovernedNormativeReference}} for the
#'   normative z-score.
#' @param covariates Covariates (e.g. \code{list(age, sex)}) for \code{ref}.
#' @return A \code{"performance_test_score"} with \code{gait_speed},
#'   \code{ambulation} and (if \code{ref}) \code{zscore}.
#' @references Perry et al. (1995); Fritz & Lusardi (2009); Perera et al. (2006).
#' @seealso [score6MWT()], [scoreTUG()]
#' @examples
#' score10MWT(time_s = 8)         # 10 m / 8 s = 1.25 m/s -> community ambulator
#' @export
score10MWT <- function(x = NULL, time_s = NULL, distance = 10,
                       pace = c("comfortable", "fast"), ref = NULL,
                       covariates = list()) {
  pace <- match.arg(pace)
  speed <- .resolve_walk_speed(x, time_s, distance)
  .perf_score("10mWT", list(gait_speed = speed, pace = pace,
                            ambulation = .ambulation_category(speed)),
              zscore = .perf_z(speed, ref, covariates))
}

#' Score a 6-minute walk test (6MWT)
#'
#' Reports the walked distance with, when the demographics are supplied, the
#' Enright & Sherrill (1998) predicted distance, percent-predicted and the lower
#' limit of normal (LLN), plus an optional normative z-score.
#'
#' @param distance_m Distance walked in 6 minutes (metres).
#' @param age,sex,height_cm,weight_kg Demographics for the Enright reference
#'   equation (all four required for the predicted value).
#' @param ref,covariates Optional normative reference / covariates for a z-score.
#' @return A \code{"performance_test_score"} with \code{distance}, and (when
#'   demographics are given) \code{predicted}, \code{percent_predicted},
#'   \code{lln} and \code{below_lln}.
#' @references Enright PL, Sherrill DL (1998). \emph{Am J Respir Crit Care Med}
#'   158(5), 1384-1387. \doi{10.1164/ajrccm.158.5.9710086}
#' @seealso [score10MWT()], [scoreTUG()]
#' @examples
#' score6MWT(450, age = 60, sex = "male", height_cm = 175, weight_kg = 75)
#' @export
score6MWT <- function(distance_m, age = NULL, sex = NULL, height_cm = NULL,
                      weight_kg = NULL, ref = NULL, covariates = list()) {
  distance_m <- as.numeric(distance_m)
  if (length(distance_m) != 1L || !is.finite(distance_m) || distance_m < 0) {
    stop("'distance_m' must be a single non-negative number.", call. = FALSE)
  }
  measure <- list(distance = distance_m)
  if (!is.null(age) && !is.null(sex) && !is.null(height_cm) &&
      !is.null(weight_kg)) {
    ref_eq <- .enright_6mwt(age, sex, height_cm, weight_kg)
    measure$predicted <- ref_eq$predicted
    measure$lln <- ref_eq$lln
    if (!is.finite(ref_eq$predicted) || ref_eq$predicted <= 0) {
      # the linear Enright equation can go non-positive for demographics well
      # outside its derivation range; do not report a nonsensical %predicted
      warning("Enright predicted 6MWD is non-positive; the demographics are ",
              "outside the equation's valid range.", call. = FALSE)
      measure$percent_predicted <- NA_real_
      measure$below_lln <- NA
    } else {
      measure$percent_predicted <- distance_m / ref_eq$predicted * 100
      measure$below_lln <- distance_m < ref_eq$lln
    }
  }
  .perf_score("6MWT", measure, zscore = .perf_z(distance_m, ref, covariates))
}

#' Score a Timed Up and Go test (TUG)
#'
#' Classifies TUG time against the standard fall-risk cut-offs (\code{< 10 s}
#' normal; \code{>= 13.5 s} elevated community-dwelling fall risk, Shumway-Cook
#' 2000; \code{>= 30 s} likely dependent, Podsiadlo & Richardson 1991), with an
#' optional normative z-score.
#'
#' @param x A TUG time in seconds, or a PhysioMoCap \code{itug_report} (its
#'   \code{total_duration} is used).
#' @param ref,covariates Optional normative reference / covariates for a z-score.
#' @return A \code{"performance_test_score"} with \code{time}, \code{category}
#'   and \code{fall_risk} (logical, \code{>= 13.5 s}).
#' @references Podsiadlo & Richardson (1991); Shumway-Cook et al. (2000).
#' @seealso [score10MWT()], [score6MWT()]
#' @examples
#' scoreTUG(15)   # >= 13.5 s -> elevated fall risk
#' @export
scoreTUG <- function(x, ref = NULL, covariates = list()) {
  time_s <- if (inherits(x, "itug_report") && !is.null(x$total_duration)) {
    as.numeric(x$total_duration)
  } else if (is.numeric(x) && length(x) == 1L) {
    as.numeric(x)
  } else {
    stop("'x' must be a TUG time (seconds) or a PhysioMoCap itug_report.",
         call. = FALSE)
  }
  if (!is.finite(time_s) || time_s <= 0) {
    stop("the TUG time must be a positive number.", call. = FALSE)
  }
  category <- if (time_s < 10) "normal"
    else if (time_s < 13.5) "borderline"
    else if (time_s < 30) "elevated_fall_risk"
    else "dependent"
  .perf_score("TUG", list(time = time_s, category = category,
                          fall_risk = time_s >= 13.5),
              zscore = .perf_z(time_s, ref, covariates))
}

#' @export
print.performance_test_score <- function(x, ...) {
  cat(sprintf("<performance_test_score> %s\n", x$test))
  fields <- setdiff(names(x), c("test", "zscore"))
  for (f in fields) {
    cat(sprintf("  %-18s %s\n", f, format(x[[f]])))
  }
  if (!is.null(x$zscore)) {
    cat(sprintf("  %-18s %.2f (pct %.1f)\n", "z-score",
                x$zscore$z, x$zscore$percentile))
  }
  invisible(x)
}
