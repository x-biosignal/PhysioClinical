# SF-36 / RAND-36 (item_recode engine) scoring.

test_that("SF-36 recodes to 0-100 and averages into eight subscales", {
  inst <- getInstrument("sf36")
  expect_equal(length(inst@items), 35L)          # 36 items minus health transition
  expect_equal(length(inst@item_recode), 35L)    # every item carries a recode map
  expect_equal(length(inst@subscales), 8L)

  rc <- inst@item_recode
  # best-health response per item = the raw value that recodes to 100
  best <- vapply(inst@items, function(it)
    as.numeric(names(rc[[it]])[which.max(rc[[it]])]), numeric(1))
  worst <- vapply(inst@items, function(it)
    as.numeric(names(rc[[it]])[which.min(rc[[it]])]), numeric(1))
  names(best) <- names(worst) <- inst@items

  sc_best <- scoreSF36(best)
  expect_true(all(abs(unlist(sc_best@subscales) - 100) < 1e-9))
  sc_worst <- scoreSF36(worst)
  expect_true(all(unlist(sc_worst@subscales) == 0))

  # a non-extreme, non-circular check: PF items at raw 2 recode to 50
  mid <- best
  mid[paste0("q", sprintf("%02d", 3:12))] <- 2
  expect_equal(scoreSF36(mid)@subscales[["physical_functioning"]], 50)
})

test_that("SF-36 is registered and discoverable", {
  expect_true("sf36" %in% listInstruments())
  expect_false(is.na(getInstrument("sf36")@source_ref))
})

test_that("item_recode generalises to any recoded instrument", {
  inst <- ClinicalInstrument(
    id = "recode_toy", items = c("a", "b"),
    item_ranges = list(a = c(1, 3), b = c(1, 3)), item_type = "ordinal",
    aggregation = "mean",
    item_recode = list(a = c("1" = 0, "2" = 50, "3" = 100),
                       b = c("1" = 100, "2" = 50, "3" = 0)))
  expect_equal(scoreInstrument(inst, c(a = 3, b = 1))@total, 100) # 100 & 100
  expect_equal(scoreInstrument(inst, c(a = 1, b = 1))@total, 50)  # 0 & 100
  # raw validated before recode; recode still applies (2 is a valid level)
  expect_equal(scoreInstrument(inst, c(a = 2, b = 2))@total, 50)  # 50 & 50

  # a valid raw response with no recode entry is an informative error
  gappy <- ClinicalInstrument(id = "recode_gap", items = "a",
    item_ranges = list(a = c(1, 3)), item_type = "ordinal",
    item_recode = list(a = c("1" = 0, "3" = 100)))
  expect_error(scoreInstrument(gappy, c(a = 2)), "no recode entry")

  # existing instruments (no recode) are unaffected
  expect_equal(scoreBarthel(stats::setNames(rep(0, 10),
               getInstrument("barthel")@items))@total, 0)
})
