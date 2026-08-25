# Bundled pain instruments: Numeric Rating Scale, Brief Pain Inventory.

test_that("Pain NRS bands a single 0-10 rating", {
  expect_equal(scorePainNRS(c(pain_intensity = 6))@total, 6)
  expect_equal(scorePainNRS(c(pain_intensity = 6))@stratum, "moderate")
  expect_equal(scorePainNRS(0)@stratum, "no_pain")       # unnamed, item order
  expect_equal(scorePainNRS(2)@stratum, "mild")
  expect_equal(scorePainNRS(9)@stratum, "severe")
  expect_equal(getInstrument("pain_nrs")@direction, "higher_worse")
  expect_error(scorePainNRS(11), "range")
})

test_that("BPI reports severity and interference as mean subscales", {
  items <- getInstrument("bpi")@items
  resp <- stats::setNames(c(8, 2, 5, 4,           # severity
                            5, 6, 5, 7, 3, 5, 6), # interference
                          items)
  sc <- scoreBPI(resp)
  expect_s4_class(sc, "ClinicalScore")
  expect_equal(sc@subscales[["severity"]], (8 + 2 + 5 + 4) / 4)      # 4.75
  expect_equal(sc@subscales[["interference"]], (5 + 6 + 5 + 7 + 3 + 5 + 6) / 7)
  expect_equal(sc@total, sum(c(8, 2, 5, 4, 5, 6, 5, 7, 3, 5, 6)) / 11)
  # mean aggregation, no standard total-score band
  expect_true(is.na(sc@stratum))
})
