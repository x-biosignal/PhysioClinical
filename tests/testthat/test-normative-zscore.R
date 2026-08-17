strata_ref <- function() {
  GovernedNormativeReference(
    "gs", "gait", "gait_speed",
    provenance = list(source = "x"), consent = list(status = "public"),
    license = list(spdx = "CC0-1.0"),
    governance = list(custodian = "lab", access_level = "open"),
    strata_vars = c("age", "sex"),
    model = list(type = "strata", table = data.frame(
      age = c(60, 60, 70, 70), sex = c("M", "F", "M", "F"),
      mean = c(1.4, 1.35, 1.3, 1.25), sd = c(0.2, 0.18, 0.15, 0.16))))
}

lms_ref <- function() {
  GovernedNormativeReference(
    "bmi", "anthro", "bmi",
    provenance = list(source = "x"), consent = list(status = "public"),
    license = list(spdx = "CC0-1.0"),
    governance = list(custodian = "lab", access_level = "open"),
    strata_vars = "age",
    model = list(type = "lms", table = data.frame(
      age = c(8, 10), L = c(-1.2, -1.5), M = c(15.5, 16.5),
      S = c(0.11, 0.12))))
}

test_that("a Gaussian stratum gives z = (value - mu) / sigma exactly", {
  ref <- strata_ref()
  r <- normativeZScore(1.0, ref, list(age = 70, sex = "M"))
  expect_equal(r$z, (1.0 - 1.3) / 0.15, tolerance = 1e-12)
  expect_equal(r$percentile, stats::pnorm(r$z) * 100, tolerance = 1e-12)
  # deviation flag: |z| clearly beyond / within the default threshold of 2
  expect_true(normativeZScore(0.9, ref, list(age = 70, sex = "M"))$deviation_flag)
  expect_false(normativeZScore(1.28, ref, list(age = 70, sex = "M"))$deviation_flag)
  # categorical exact + numeric nearest (68 -> 70, 'F' stratum)
  expect_equal(normativeZScore(1.25, ref, list(age = 68, sex = "F"))$z, 0,
               tolerance = 1e-12)
})

test_that("LMS z and back-transform round-trip a percentile table", {
  ref <- lms_ref()
  # at the median M the z is 0
  expect_equal(normativeZScore(16.5, ref, list(age = 10))$z, 0, tolerance = 1e-9)
  # back-transform known z -> value -> z reproduces the input z
  zs <- c(-2, -1, -0.5, 1, 2)
  vals <- vapply(zs, function(z) .lms_value(z, -1.5, 16.5, 0.12), numeric(1))
  recovered <- vapply(vals, function(v) normativeZScore(v, ref, list(age = 10))$z,
                      numeric(1))
  expect_equal(recovered, zs, tolerance = 1e-9)
  # L = 0 reduces to the log-normal form
  expect_equal(.lms_z(exp(0.1), 0, 1, 0.1), 1, tolerance = 1e-12)
})

test_that("missing or unsupported strata raise an informative error", {
  ref <- strata_ref()
  expect_error(normativeZScore(1.0, ref, list(sex = "M")), "age")
  expect_error(normativeZScore(1.0, ref, list(age = 70, sex = "Z")),
               "categorical|stratum")
  expect_error(normativeZScore(1.0, ref, list(age = 70)), "sex")
  # no silent NA: a positive z is returned, never NA, for a valid match
  expect_false(is.na(normativeZScore(1.0, ref, list(age = 70, sex = "M"))$z))
})

test_that("out-of-support covariates set the extrapolation flag", {
  ref <- strata_ref()
  expect_false(normativeZScore(1.3, ref, list(age = 65, sex = "M"))$extrapolation)
  expect_true(normativeZScore(1.3, ref, list(age = 90, sex = "M"))$extrapolation)
})

test_that("matchStratum picks the nearest numeric / exact categorical stratum", {
  ref <- strata_ref()
  row <- matchStratum(ref, list(age = 62, sex = "F"))
  expect_equal(row$age, 60)
  expect_equal(as.character(row$sex), "F")
  expect_false(attr(row, "extrapolation"))
})

test_that("extrapolation is judged within the matched categorical stratum", {
  # female support [60,70], male support [60,90]
  ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
    provenance = list(source = "x"), consent = list(status = "public"),
    license = list(spdx = "CC0-1.0"),
    governance = list(custodian = "lab", access_level = "open"),
    strata_vars = c("age", "sex"),
    model = list(type = "strata", table = data.frame(
      age = c(60, 90, 60, 70), sex = c("M", "M", "F", "F"),
      mean = 1.3, sd = 0.2)))
  expect_true(normativeZScore(1.0, ref, list(age = 85, sex = "F"))$extrapolation)
  expect_false(normativeZScore(1.0, ref, list(age = 85, sex = "M"))$extrapolation)
  expect_false(normativeZScore(1.0, ref, list(age = 65, sex = "F"))$extrapolation)
})

test_that("unsupported model type and non-finite value error, not silently score", {
  bad_type <- GovernedNormativeReference("m", "gait", "m",
    provenance = list(source = "x"), consent = list(status = "public"),
    license = list(spdx = "CC0-1.0"),
    governance = list(custodian = "lab", access_level = "open"),
    strata_vars = "sex",
    model = list(type = "gamma", table = data.frame(sex = "M", mean = 1, sd = 1)))
  expect_error(normativeZScore(1.0, bad_type, list(sex = "M")),
               "unsupported.*model type")

  ref <- strata_ref()
  expect_error(normativeZScore(NA, ref, list(age = 70, sex = "M")), "finite")
  expect_error(normativeZScore(c(1, 2), ref, list(age = 70, sex = "M")),
               "single")
})

test_that("normativeDeviation scores a metric table row-wise", {
  ref <- strata_ref()
  tbl <- data.frame(value = c(1.0, 1.35), age = c(70, 60), sex = c("M", "F"))
  out <- normativeDeviation(tbl, ref)
  expect_true(all(c("z", "percentile", "deviation_flag", "extrapolation") %in%
                    names(out)))
  expect_equal(out$z[1], (1.0 - 1.3) / 0.15, tolerance = 1e-12)
  expect_equal(out$z[2], 0, tolerance = 1e-12)
  expect_error(normativeDeviation(data.frame(age = 70, sex = "M"), ref), "value")
  expect_error(normativeDeviation(data.frame(value = 1, age = 70), ref), "sex")
  # a 0-row table keeps the 4-column output schema
  z0 <- normativeDeviation(
    data.frame(value = numeric(0), age = numeric(0), sex = character(0)), ref)
  expect_equal(nrow(z0), 0L)
  expect_true(all(c("z", "percentile", "deviation_flag", "extrapolation") %in%
                    names(z0)))
})
