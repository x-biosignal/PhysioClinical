test_that("10mWT gait speed and ambulation category (manual + MoCap paths)", {
  # manual: 10 m / 8 s = 1.25 m/s -> community ambulator
  s <- score10MWT(time_s = 8)
  expect_equal(s$gait_speed, 1.25)
  expect_equal(s$ambulation, "community")
  expect_equal(score10MWT(0.6)$ambulation, "limited_community")
  expect_equal(score10MWT(0.3)$ambulation, "household")
  expect_error(score10MWT(time_s = 0), "positive")
  expect_error(score10MWT(), "provide")

  # signal-derived: gait speed from a synthetic MoCap 10 m walk matches 1.25
  skip_if_not_installed("PhysioMoCap")
  sr <- 100
  pos <- 10 * (seq(0, 8, by = 1 / sr) / 8)      # linear 0..10 m over 8 s
  wr <- PhysioMoCap::instrumented10mWT(pos, sampling_rate = sr,
                                       total_distance = 10)
  expect_equal(score10MWT(wr)$gait_speed, 1.25, tolerance = 1e-6)
})

test_that("6MWT Enright predicted / LLN match the worked example", {
  # Enright & Sherrill 1998, male 60y 175cm 75kg:
  #   pred = 7.57*175 - 5.02*60 - 1.76*75 - 309 = 582.55; LLN = pred - 153
  s <- score6MWT(450, age = 60, sex = "male", height_cm = 175, weight_kg = 75)
  expect_equal(s$predicted, 582.55, tolerance = 1e-6)
  expect_equal(s$lln, 582.55 - 153, tolerance = 1e-6)
  expect_equal(s$percent_predicted, 450 / 582.55 * 100, tolerance = 1e-9)
  expect_false(s$below_lln)
  # female equation differs
  sf <- score6MWT(400, age = 55, sex = "female", height_cm = 165,
                  weight_kg = 65)
  expect_equal(sf$predicted, 2.11 * 165 - 5.78 * 55 - 2.29 * 65 + 667,
               tolerance = 1e-6)
  # distance only (no demographics) still scores
  s0 <- score6MWT(400)
  expect_equal(s0$distance, 400)
  expect_null(s0$predicted)
  expect_error(score6MWT(400, age = 60, sex = "x", height_cm = 175,
                         weight_kg = 75), "male/female")
  # demographics outside the equation range -> non-positive predicted must warn
  # and not report a nonsensical percent / below_lln
  expect_warning(bad <- score6MWT(300, age = 95, sex = "male", height_cm = 130,
                                  weight_kg = 150), "valid range")
  expect_true(bad$predicted <= 0)
  expect_true(is.na(bad$percent_predicted))
  expect_true(is.na(bad$below_lln))
})

test_that("a non-finite resolved gait speed errors cleanly (not cryptically)", {
  expect_error(score10MWT(NaN), "finite")
  expect_error(
    score10MWT(structure(list(gait_speed = NA_real_),
                         class = "walk_test_report")), "finite")
  expect_error(
    score10MWT(structure(data.frame(walking_speed = c(NA, NA)),
                         class = c("gait_parameters", "data.frame"))), "finite")
})

test_that("TUG fall-risk cut-offs", {
  expect_equal(scoreTUG(8)$category, "normal")
  expect_false(scoreTUG(8)$fall_risk)
  expect_equal(scoreTUG(12)$category, "borderline")
  expect_true(scoreTUG(15)$fall_risk)              # >= 13.5 s
  expect_equal(scoreTUG(15)$category, "elevated_fall_risk")
  expect_equal(scoreTUG(35)$category, "dependent")
  expect_error(scoreTUG(-1), "positive")
  expect_error(scoreTUG("nope"), "TUG time")
})

test_that("tests hook to the normative z-score engine", {
  ref <- GovernedNormativeReference(
    "gs", "gait", "gait_speed", provenance = list(source = "x"),
    consent = list(status = "public"), license = list(spdx = "CC0-1.0"),
    governance = list(custodian = "lab", access_level = "open"),
    strata_vars = "sex",
    model = list(type = "strata",
                 table = data.frame(sex = "M", mean = 1.3, sd = 0.2)))
  s <- score10MWT(time_s = 8, ref = ref, covariates = list(sex = "M"))
  expect_equal(s$zscore$z, (1.25 - 1.3) / 0.2, tolerance = 1e-9)
  expect_null(score10MWT(time_s = 8)$zscore)       # no ref -> no z
  expect_output(print(s), "z-score")
})
