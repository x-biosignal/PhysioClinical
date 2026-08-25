# Bundled fatigue instruments: FSS (mean 1-7), MFIS (sum 0-84).

test_that("FSS averages nine items with a mean >= 4 cutoff", {
  items <- getInstrument("fss")@items
  expect_equal(scoreFSS(stats::setNames(rep(6, 9), items))@total, 6)
  expect_equal(scoreFSS(stats::setNames(rep(6, 9), items))@stratum,
               "significant_fatigue")
  expect_equal(scoreFSS(stats::setNames(rep(2, 9), items))@stratum,
               "no_significant_fatigue")
  # a mean just below 4 stays below the cutoff (fractional-band handling)
  below <- scoreFSS(stats::setNames(c(4, 4, 4, 4, 4, 4, 4, 4, 3), items))
  expect_equal(below@total, 35 / 9)
  expect_equal(below@stratum, "no_significant_fatigue")
  # exactly 4 is significant
  expect_equal(scoreFSS(stats::setNames(rep(4, 9), items))@stratum,
               "significant_fatigue")
  expect_equal(getInstrument("fss")@direction, "higher_worse")
})

test_that("MFIS sums to 0-84 with physical/cognitive/psychosocial subscales", {
  items <- getInstrument("mfis")@items
  sc <- scoreMFIS(stats::setNames(rep(2, 21), items))
  expect_equal(sc@total, 42)
  expect_equal(sc@stratum, "fatigued")               # >= 38
  expect_equal(sc@subscales[["physical"]], 18)        # 9 items x 2
  expect_equal(sc@subscales[["cognitive"]], 20)       # 10 items x 2
  expect_equal(sc@subscales[["psychosocial"]], 4)     # 2 items x 2
  expect_equal(unname(sum(sc@subscales)), 42)         # subscales partition
  expect_equal(scoreMFIS(stats::setNames(rep(1, 21), items))@stratum,
               "not_fatigued")
})
