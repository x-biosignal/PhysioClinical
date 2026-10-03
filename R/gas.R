# Goal Attainment Scaling (Kiresuk & Sherman 1968; Turner-Stokes 2009).

#' Define a Goal Attainment Scaling goal
#'
#' Describes one GAS goal: its attainment levels (typically \code{-2:2} with 0 =
#' expected outcome), a weight, and an optional ICF linkage. When both
#' \code{importance} and \code{difficulty} are given the (Turner-Stokes) weight
#' is their product; otherwise \code{weight} is used (default 1, i.e. unweighted
#' GAS).
#'
#' @param description Free-text goal description.
#' @param levels Ordered numeric attainment levels (must include 0, the expected
#'   outcome); default \code{-2:2}.
#' @param weight Goal weight when \code{importance}/\code{difficulty} are not
#'   supplied (default 1, positive).
#' @param importance,difficulty Optional 0+ ratings; if both given the weight is
#'   \code{importance * difficulty}.
#' @param icf_tag Optional ICF code (e.g. \code{"d450"}) linking the goal to the
#'   International Classification of Functioning.
#' @return A \code{"gas_goal"} object.
#' @references Kiresuk & Sherman (1968); Turner-Stokes (2009).
#' @seealso [scoreGAS()]
#' @examples
#' defineGoal("Walk 100 m unaided", importance = 3, difficulty = 2,
#'            icf_tag = "d450")
#' @export
defineGoal <- function(description, levels = -2:2, weight = 1,
                       importance = NULL, difficulty = NULL, icf_tag = NULL) {
  levels <- sort(unique(as.numeric(levels)))
  if (length(levels) < 2L || !any(levels == 0)) {
    stop("'levels' must be >= 2 ordered values including 0 (expected outcome).",
         call. = FALSE)
  }
  if (!is.null(importance) && !is.null(difficulty)) {
    importance <- as.numeric(importance)
    difficulty <- as.numeric(difficulty)
    if (!is.finite(importance) || importance < 0 || !is.finite(difficulty) ||
        difficulty < 0) {
      stop("'importance' and 'difficulty' must be non-negative.", call. = FALSE)
    }
    weight <- importance * difficulty
  } else if (!is.null(importance) || !is.null(difficulty)) {
    # weighting needs BOTH ratings; one alone would silently stay unweighted
    warning("both 'importance' and 'difficulty' are needed to weight a goal; ",
            "the given one is ignored (goal stays unweighted).", call. = FALSE)
  }
  weight <- as.numeric(weight)
  if (length(weight) != 1L || !is.finite(weight) || weight <= 0) {
    stop("the goal weight must be a single positive number.", call. = FALSE)
  }
  structure(list(description = as.character(description), levels = levels,
                 weight = weight, importance = importance,
                 difficulty = difficulty,
                 icf_tag = if (!is.null(icf_tag)) as.character(icf_tag)),
            class = "gas_goal")
}

#' Score Goal Attainment Scaling (GAS T-score)
#'
#' Computes the standardized GAS T-score across a set of goals given their
#' attained levels:
#' \deqn{T = 50 + \frac{10 \sum_i w_i x_i}{\sqrt{(1-\rho)\sum_i w_i^2 +
#'   \rho (\sum_i w_i)^2}}}
#' where \eqn{x_i} is the attained level, \eqn{w_i} the weight and \eqn{\rho}
#' the assumed inter-goal correlation. All goals at their expected level
#' (\eqn{x_i = 0}) give \eqn{T = 50}.
#'
#' @param goals A \code{\link{defineGoal}} object or a list of them.
#' @param attained_levels Numeric attained level for each goal (each within that
#'   goal's \code{levels}).
#' @param rho Assumed inter-goal correlation in \code{[0, 1)}; default 0.3.
#' @return A \code{"gas_result"} with the T-score, per-goal weights/levels and
#'   \code{rho}.
#' @references Kiresuk & Sherman (1968); Turner-Stokes (2009).
#' @seealso [defineGoal()], [gasSummary()]
#' @examples
#' g1 <- defineGoal("Transfers", importance = 3, difficulty = 2)
#' g2 <- defineGoal("Stairs", importance = 2, difficulty = 3)
#' scoreGAS(list(g1, g2), attained_levels = c(1, 0))
#' @export
scoreGAS <- function(goals, attained_levels, rho = 0.3) {
  if (inherits(goals, "gas_goal")) goals <- list(goals)
  if (!is.list(goals) || length(goals) == 0L ||
      !all(vapply(goals, inherits, logical(1), "gas_goal"))) {
    stop("'goals' must be a gas_goal or a non-empty list of gas_goal objects.",
         call. = FALSE)
  }
  x <- as.numeric(attained_levels)
  if (length(x) != length(goals)) {
    stop("'attained_levels' must have one value per goal.", call. = FALSE)
  }
  if (anyNA(x)) {
    stop("'attained_levels' must not contain NA.", call. = FALSE)
  }
  if (!is.numeric(rho) || length(rho) != 1L || rho < 0 || rho >= 1) {
    stop("'rho' must be a single value in [0, 1).", call. = FALSE)
  }
  for (i in seq_along(goals)) {
    lv <- goals[[i]]$levels
    if (x[i] < min(lv) || x[i] > max(lv)) {
      stop(sprintf("attained level %s is outside goal %d's range [%s, %s].",
                   x[i], i, min(lv), max(lv)), call. = FALSE)
    }
  }
  w <- vapply(goals, function(g) g$weight, numeric(1))
  num <- 10 * sum(w * x)
  den <- sqrt((1 - rho) * sum(w^2) + rho * sum(w)^2)
  structure(list(t_score = 50 + num / den, goals = goals, attained = x,
                 weights = w, rho = rho, weighted = any(w != 1)),
            class = "gas_result")
}

#' Tabulate a GAS result
#'
#' @param object A \code{"gas_result"} from \code{\link{scoreGAS}}.
#' @param ... Unused.
#' @return A \code{data.frame} with one row per goal (description, ICF tag,
#'   weight, attained level and its weighted contribution) plus the T-score as an
#'   attribute.
#' @seealso [scoreGAS()]
#' @export
gasSummary <- function(object, ...) {
  if (!inherits(object, "gas_result")) {
    stop("'object' must be a gas_result from scoreGAS().", call. = FALSE)
  }
  goals <- object$goals
  df <- data.frame(
    description = vapply(goals, function(g) g$description, character(1)),
    icf_tag = vapply(goals, function(g)
      if (is.null(g$icf_tag)) NA_character_ else g$icf_tag, character(1)),
    weight = object$weights,
    attained = object$attained,
    contribution = object$weights * object$attained,
    stringsAsFactors = FALSE)
  attr(df, "t_score") <- object$t_score
  df
}

#' @export
print.gas_result <- function(x, ...) {
  cat(sprintf("<gas_result> T = %.2f  (%d goal(s), %s, rho = %s)\n",
              x$t_score, length(x$goals),
              if (isTRUE(x$weighted)) "weighted" else "unweighted",
              format(x$rho)))
  s <- gasSummary(x)
  print(s[, c("description", "weight", "attained", "contribution")],
        row.names = FALSE)
  invisible(x)
}
