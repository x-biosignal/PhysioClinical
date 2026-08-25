# Bundled muscle-strength instrument: MRC sum score (0-60).

test_that("MRC sum score totals 0-60 with limb/side subscales", {
  items <- getInstrument("mrc_sum")@items
  full <- scoreMRCSum(stats::setNames(rep(5, 12), items))
  expect_equal(full@total, 60)
  expect_equal(full@stratum, "no_weakness")
  # overlapping subscales (upper/lower and left/right both partition the 12
  # movements) each sum to 30 while the total is computed over all items
  expect_equal(full@subscales[["upper_limb"]], 30)
  expect_equal(full@subscales[["lower_limb"]], 30)
  expect_equal(full@subscales[["left"]], 30)
  expect_equal(full@subscales[["right"]], 30)

  expect_equal(scoreMRCSum(stats::setNames(rep(3, 12), items))@total, 36)
  expect_equal(scoreMRCSum(stats::setNames(rep(3, 12), items))@stratum,
               "weakness")                            # 36-47
  expect_equal(scoreMRCSum(stats::setNames(rep(2, 12), items))@stratum,
               "severe_weakness")                     # < 36

  # grades are 0-5 integers
  bad <- stats::setNames(rep(5, 12), items); bad["elbow_flexion_r"] <- 6
  expect_error(scoreMRCSum(bad), "range")
})
