# Bundled cognitive-screening instruments: MMSE, MoCA.

test_that("MMSE totals 0-30 with domain subscales and severity strata", {
  items <- getInstrument("mmse")@items
  full <- stats::setNames(c(5, 5, 3, 5, 3, 2, 1, 3, 1, 1, 1), items)
  sc <- scoreMMSE(full)
  expect_s4_class(sc, "ClinicalScore")
  expect_equal(sc@total, 30)
  expect_equal(sc@stratum, "no_impairment")
  # subscales partition the items, so they sum to the total
  expect_equal(sc@subscales[["orientation"]], 10)   # time + place
  expect_equal(sc@subscales[["language"]], 8)        # naming..writing
  expect_equal(unname(sum(sc@subscales)), 30)

  expect_equal(scoreMMSE(stats::setNames(rep(0, 11), items))@stratum,
               "severe_impairment")
  # mild band (18-23): drop recall (-3) and reduce attention to 1 (-4) => 23
  mild <- full; mild["recall"] <- 0; mild["attention_calculation"] <- 1
  expect_equal(scoreMMSE(mild)@total, 23)
  expect_equal(scoreMMSE(mild)@stratum, "mild_impairment")

  # ordinal levels must be integers and within range
  bad <- full; bad["recall"] <- 2.5
  expect_error(scoreMMSE(bad), "integer")
  bad2 <- full; bad2["orientation_time"] <- 6
  expect_error(scoreMMSE(bad2), "range")
})

test_that("MoCA totals 0-30 with the <26 impairment cutoff", {
  items <- getInstrument("moca")@items
  full <- stats::setNames(c(5, 3, 6, 3, 2, 5, 6), items)
  expect_equal(scoreMoCA(full)@total, 30)
  expect_equal(scoreMoCA(full)@stratum, "normal")

  # 20 => mild band (18-25)
  mild <- full; mild["delayed_recall"] <- 0; mild["attention"] <- 1
  expect_equal(scoreMoCA(mild)@total, 20)
  expect_equal(scoreMoCA(mild)@stratum, "mild_impairment")

  expect_equal(scoreMoCA(stats::setNames(rep(0, 7), items))@stratum,
               "moderate_severe_impairment")
})
