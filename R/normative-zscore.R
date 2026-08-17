# z-score / deviation engine over a governed normative reference. The reference
# (WS7-08) declares its stratification variables and carries either a stratified
# mean/sd table or LMS (Cole 1990) coefficients.

# Cole (1990) LMS z-score: L = lambda (Box-Cox power), M = median, S = CV.
.lms_z <- function(x, L, M, S) {
  if (any(!is.finite(c(L, M, S))) || M <= 0 || S <= 0) {
    stop("LMS parameters must be finite with M > 0 and S > 0.", call. = FALSE)
  }
  if (!is.finite(x) || x <= 0) {
    stop("an LMS z-score requires a positive value.", call. = FALSE)
  }
  if (abs(L) < 1e-8) log(x / M) / S else ((x / M)^L - 1) / (L * S)
}

# LMS back-transform: the measurement value at a given z.
.lms_value <- function(z, L, M, S) {
  if (abs(L) < 1e-8) M * exp(S * z) else M * (1 + L * S * z)^(1 / L)
}

.nr_model_table <- function(ref) {
  tbl <- ref@model$table
  if (is.null(tbl) || !is.data.frame(tbl) || nrow(tbl) == 0L) {
    stop("the reference has no usable model table.", call. = FALSE)
  }
  tbl
}

#' Match the normative stratum for a set of covariates
#'
#' Selects the row of a governed normative reference's model table that matches
#' the supplied covariates: categorical stratification variables (e.g. sex) are
#' matched exactly, numeric ones (e.g. age, speed) by nearest value. A covariate
#' falling outside the tabulated range is flagged as an extrapolation.
#'
#' @param ref A \code{\linkS4class{GovernedNormativeReference}}.
#' @param covariates Named list of covariate values covering the reference's
#'   \code{strata_vars}.
#' @return A one-row \code{data.frame} (the matched stratum) with an
#'   \code{"extrapolation"} attribute (logical).
#' @seealso [normativeZScore()], [normativeDeviation()]
#' @examples
#' ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
#'   provenance = list(source = "x"), consent = list(status = "public"),
#'   license = list(spdx = "CC0-1.0"),
#'   governance = list(custodian = "lab", access_level = "open"),
#'   strata_vars = c("age", "sex"),
#'   model = list(type = "strata", table = data.frame(
#'     age = c(60, 70), sex = "M", mean = c(1.4, 1.3), sd = 0.2)))
#' matchStratum(ref, list(age = 68, sex = "M"))
#' @importFrom methods is
#' @export
matchStratum <- function(ref, covariates) {
  if (!methods::is(ref, "GovernedNormativeReference")) {
    stop("'ref' must be a GovernedNormativeReference.", call. = FALSE)
  }
  tbl <- .nr_model_table(ref)
  vars <- ref@strata_vars
  covariates <- as.list(covariates)

  sub <- tbl
  for (v in vars) {
    if (is.null(covariates[[v]])) {
      stop(sprintf("covariate '%s' is required for this reference.", v),
           call. = FALSE)
    }
    if (is.null(tbl[[v]])) {
      stop(sprintf("the model table has no stratum column '%s'.", v),
           call. = FALSE)
    }
    if (!is.numeric(tbl[[v]])) {
      sub <- sub[as.character(sub[[v]]) == as.character(covariates[[v]]), ,
                 drop = FALSE]
    }
  }
  if (nrow(sub) == 0L) {
    stop("no stratum matches the supplied categorical covariates.",
         call. = FALSE)
  }

  numvars <- vars[vapply(vars, function(v) is.numeric(tbl[[v]]), logical(1))]
  extrap <- FALSE
  if (length(numvars)) {
    dist <- numeric(nrow(sub))
    for (v in numvars) {
      cv <- as.numeric(covariates[[v]])
      # scale each variable's distance by its tabulated range so a large-scale
      # covariate (e.g. age ~70) does not dominate a small-scale one (speed ~1.3)
      rng <- diff(range(tbl[[v]]))
      dist <- dist + abs(sub[[v]] - cv) / (if (rng > 0) rng else 1)
      # the match came from the categorical subset `sub`, so its support is the
      # subset's range, not the whole column (which may span other strata)
      if (cv < min(sub[[v]]) || cv > max(sub[[v]])) extrap <- TRUE
    }
    sub <- sub[which.min(dist), , drop = FALSE]
  } else {
    sub <- sub[1L, , drop = FALSE]
  }
  attr(sub, "extrapolation") <- extrap
  sub
}

#' Normative z-score / percentile for an observation
#'
#' Standardizes an observed \code{value} against a governed normative reference,
#' selecting the covariate-matched stratum and applying either a Gaussian
#' \eqn{(value - \mu)/\sigma} (stratified mean/sd model) or the Cole (1990) LMS
#' transform (LMS model). An unmatched or unsupported stratum raises an error
#' rather than returning a silent \code{NA}.
#'
#' @param value Numeric observed value.
#' @param ref A \code{\linkS4class{GovernedNormativeReference}}.
#' @param covariates Named list of covariates (e.g. \code{list(age = 68,
#'   sex = "M")}) covering the reference's \code{strata_vars}.
#' @param deviation_z Absolute z above which \code{deviation_flag} is set
#'   (default 2).
#' @return A list with \code{z}, \code{percentile} (0-100), \code{deviation_flag}
#'   and \code{extrapolation}.
#' @references Cole TJ (1990). The LMS method for constructing normalized growth
#'   standards. \emph{Eur J Clin Nutr} 44(1), 45-60.
#' @seealso [matchStratum()], [normativeDeviation()]
#' @examples
#' ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
#'   provenance = list(source = "x"), consent = list(status = "public"),
#'   license = list(spdx = "CC0-1.0"),
#'   governance = list(custodian = "lab", access_level = "open"),
#'   strata_vars = "sex",
#'   model = list(type = "strata",
#'                table = data.frame(sex = "M", mean = 1.3, sd = 0.2)))
#' normativeZScore(1.0, ref, list(sex = "M"))
#' @importFrom methods is
#' @export
normativeZScore <- function(value, ref, covariates = list(), deviation_z = 2) {
  if (!methods::is(ref, "GovernedNormativeReference")) {
    stop("'ref' must be a GovernedNormativeReference.", call. = FALSE)
  }
  value <- as.numeric(value)
  if (length(value) != 1L) {
    stop("'value' must be a single observation; use normativeDeviation() for ",
         "a table.", call. = FALSE)
  }
  if (!is.finite(value)) {
    stop("'value' must be a finite numeric observation.", call. = FALSE)
  }
  row <- matchStratum(ref, covariates)
  extrap <- isTRUE(attr(row, "extrapolation"))
  mtype <- if (is.null(ref@model$type)) "strata" else ref@model$type
  if (!mtype %in% c("strata", "lms")) {
    stop(sprintf("unsupported normative model type '%s'; expected 'strata' ",
                 mtype), "or 'lms'.", call. = FALSE)
  }

  if (identical(mtype, "lms")) {
    if (!all(c("L", "M", "S") %in% names(row))) {
      stop("an LMS reference stratum needs L, M and S columns.", call. = FALSE)
    }
    z <- .lms_z(value, row$L[1L], row$M[1L], row$S[1L])
  } else {
    if (!all(c("mean", "sd") %in% names(row))) {
      stop("a stratified reference stratum needs 'mean' and 'sd' columns.",
           call. = FALSE)
    }
    if (!is.finite(row$sd[1L]) || row$sd[1L] <= 0) {
      stop("the matched stratum sd must be finite and positive.", call. = FALSE)
    }
    z <- (value - row$mean[1L]) / row$sd[1L]
  }
  list(z = z, percentile = stats::pnorm(z) * 100,
       deviation_flag = abs(z) > deviation_z, extrapolation = extrap)
}

#' Batch normative deviation over a metric table
#'
#' Applies \code{\link{normativeZScore}} to every row of a metric table: each row
#' supplies a \code{value} plus the covariate columns named by the reference's
#' \code{strata_vars}.
#'
#' @param metric_table A \code{data.frame} with a \code{value} column and one
#'   column per \code{ref} stratification variable.
#' @param ref A \code{\linkS4class{GovernedNormativeReference}}.
#' @param deviation_z Deviation-flag threshold (see [normativeZScore()]).
#' @return \code{metric_table} with added \code{z}, \code{percentile},
#'   \code{deviation_flag} and \code{extrapolation} columns.
#' @seealso [normativeZScore()]
#' @export
normativeDeviation <- function(metric_table, ref, deviation_z = 2) {
  df <- as.data.frame(metric_table)
  if (!"value" %in% names(df)) {
    stop("'metric_table' must have a 'value' column.", call. = FALSE)
  }
  vars <- ref@strata_vars
  miss <- setdiff(vars, names(df))
  if (length(miss)) {
    stop("'metric_table' is missing covariate column(s): ",
         paste(miss, collapse = ", "), ".", call. = FALSE)
  }
  out <- do.call(rbind, lapply(seq_len(nrow(df)), function(i) {
    cov <- as.list(df[i, vars, drop = FALSE])
    r <- normativeZScore(df$value[i], ref, cov, deviation_z = deviation_z)
    data.frame(z = r$z, percentile = r$percentile,
               deviation_flag = r$deviation_flag,
               extrapolation = r$extrapolation)
  }))
  if (is.null(out)) {   # a 0-row table still returns the 4-column schema
    out <- data.frame(z = numeric(0), percentile = numeric(0),
                      deviation_flag = logical(0), extrapolation = logical(0))
  }
  cbind(df, out)
}
