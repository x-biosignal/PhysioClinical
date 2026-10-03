# Bundled ADL / IADL instruments: Barthel, Katz, Lawton-Brody.

test_that("Barthel Index scores and strata are correct", {
  items <- getInstrument("barthel")@items
  full <- stats::setNames(c(10, 5, 5, 10, 10, 10, 10, 15, 15, 10), items)
  sc <- scoreBarthel(full)
  expect_s4_class(sc, "ClinicalScore")
  expect_equal(sc@total, 100)
  expect_equal(sc@stratum, "independent")

  none <- stats::setNames(rep(0, 10), items)
  expect_equal(scoreBarthel(none)@total, 0)
  expect_equal(scoreBarthel(none)@stratum, "total_dependence")

  # a moderate-dependence case: 65
  mod <- full; mod["transfers"] <- 10; mod["mobility"] <- 5
  mod["stairs"] <- 0; mod["bathing"] <- 0; mod["dressing"] <- 5
  expect_equal(scoreBarthel(mod)@stratum, "moderate_dependence")

  # weights are enforced: 7 is not an allowed Barthel level
  bad <- full; bad["feeding"] <- 7
  expect_error(scoreBarthel(bad), "allowed level")
  # out-of-range enforced
  bad2 <- full; bad2["bathing"] <- 10
  expect_error(scoreBarthel(bad2), "range")
})

test_that("Katz Index scores 0-6 with impairment strata", {
  expect_equal(scoreKatz(stats::setNames(rep(1, 6),
               getInstrument("katz_adl")@items))@total, 6)
  expect_equal(scoreKatz(stats::setNames(rep(1, 6),
               getInstrument("katz_adl")@items))@stratum, "independent")
  expect_equal(scoreKatz(c(bathing = 0, dressing = 0, toileting = 1,
                           transferring = 1, continence = 0, feeding = 0)
               )@stratum, "severe_impairment")
})

test_that("Lawton IADL sums 0-8 and asserts no severity band", {
  full <- scoreLawton(stats::setNames(rep(1, 8),
                                      getInstrument("lawton_iadl")@items))
  expect_equal(full@total, 8)
  expect_true(is.na(full@stratum))            # no standard total-score band
  # abbreviated male version (5 items) via prorate
  male <- scoreLawton(c(telephone = 1, shopping = 1, transportation = 1,
                        medication = 1, finances = 0), missing = "prorate")
  expect_equal(male@total, (4) * (8 / 5))     # prorated to the full 8-item scale
})

test_that("ADL/IADL instruments are registered and discoverable", {
  ids <- listInstruments()
  expect_true(all(c("barthel", "katz_adl", "lawton_iadl") %in% ids))
  # every ADL instrument declares ordinal items and a provenance citation
  for (id in c("barthel", "katz_adl", "lawton_iadl")) {
    inst <- getInstrument(id)
    expect_true(all(inst@item_type == "ordinal"))
    expect_false(is.na(inst@source_ref))
  }
})
