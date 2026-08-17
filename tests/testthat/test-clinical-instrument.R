library(testthat)
library(PhysioClinical)

# A hand-built two-subscale instrument used for the exact-total checks.
fixture_instrument <- function() {
  ClinicalInstrument(
    id = "fx", name = "Fixture", items = c("a1", "a2", "a3", "b1", "b2"),
    item_ranges = list(a1 = c(0, 2), a2 = c(0, 2), a3 = c(0, 2),
                       b1 = c(0, 3), b2 = c(0, 3)),
    item_type = "ordinal", aggregation = "sum",
    subscales = list(motor = c("a1", "a2", "a3"), sensory = c("b1", "b2")),
    strata = list(list(label = "low", lower = 0, upper = 5),
                  list(label = "high", lower = 6, upper = 12)))
}

test_that("scoring reproduces the hand-computed total and every subscale", {
  inst <- fixture_instrument()
  sc <- scoreInstrument(inst, c(a1 = 2, a2 = 1, a3 = 2, b1 = 3, b2 = 2))
  expect_s4_class(sc, "ClinicalScore")
  expect_equal(sc@total, 10)                       # 2+1+2+3+2
  expect_equal(sc@subscales[["motor"]], 5)         # 2+1+2
  expect_equal(sc@subscales[["sensory"]], 5)       # 3+2
  expect_equal(sc@stratum, "high")                 # 10 in [6, 12]
  expect_equal(sc@instrument_id, "fx")
})

test_that("out-of-range and wrong-level items raise informative errors", {
  inst <- fixture_instrument()
  expect_error(scoreInstrument(inst, c(a1 = 5, a2 = 1, a3 = 2, b1 = 3, b2 = 2)),
               "outside its range")
  expect_error(scoreInstrument(inst, c(a1 = 1.5, a2 = 1, a3 = 2, b1 = 3, b2 = 2)),
               "must be an integer")
  expect_error(scoreInstrument(inst, c(zzz = 1, a2 = 1, a3 = 2, b1 = 3, b2 = 2)),
               "Unknown item")
})

test_that("missing = 'prorate' matches the manual proration formula", {
  inst <- fixture_instrument()
  resp <- c(a1 = 2, a2 = 1, a3 = 2, b1 = 3, b2 = NA)   # 4 of 5 observed
  sc <- scoreInstrument(inst, resp, missing = "prorate")
  # sensory: b1 = 3 observed of 2 -> 3 * (2/1) = 6 ; motor complete = 5
  expect_equal(sc@subscales[["sensory"]], 3 * (2 / 1))
  expect_equal(sc@subscales[["motor"]], 5)
  # the total equals the sum of the (prorated) subscales, as in the complete case
  expect_equal(sc@total, sc@subscales[["motor"]] + sc@subscales[["sensory"]])
  expect_equal(sc@total, 11)
  expect_equal(length(sc@items_used), 4L)
})

test_that("proration keeps total == sum of subscales (invariant)", {
  inst <- fixture_instrument()
  for (resp in list(c(a1 = 2, a2 = NA, a3 = 2, b1 = 3, b2 = 1),
                    c(a1 = 1, a2 = 1, a3 = 1, b1 = NA, b2 = 2),
                    c(a1 = 2, a2 = 2, a3 = 2, b1 = 3, b2 = 3))) {
    sc <- scoreInstrument(inst, resp, missing = "prorate")
    expect_equal(sc@total, sum(sc@subscales))
  }
})

test_that("mean-aggregation proration is the mean of the observed items", {
  inst <- ClinicalInstrument(
    id = "mm", items = c("x1", "x2", "x3"),
    item_ranges = list(x1 = c(0, 10), x2 = c(0, 10), x3 = c(0, 10)),
    aggregation = "mean")
  sc <- scoreInstrument(inst, c(x1 = 4, x2 = 8, x3 = NA), missing = "prorate")
  expect_equal(sc@total, mean(c(4, 8)))
})

test_that("missing = 'na' and 'error' behave as documented", {
  inst <- fixture_instrument()
  resp <- c(a1 = 2, a2 = 1, a3 = 2, b1 = 3, b2 = NA)
  na_sc <- scoreInstrument(inst, resp, missing = "na")
  expect_true(is.na(na_sc@total))
  expect_true(is.na(na_sc@subscales[["sensory"]]))
  expect_equal(na_sc@subscales[["motor"]], 5)         # complete subscale scored
  expect_error(scoreInstrument(inst, resp, missing = "error"), "Missing response")
})

test_that("assignStratum returns the correct band at exact boundary values", {
  skip_if_not_installed("yaml")
  berg <- getInstrument("berg")
  at <- function(total) {
    v <- rep(0, 14); names(v) <- berg@items
    # distribute the total across items (each 0-4) deterministically
    i <- 1L
    while (total > 0) {
      add <- min(4, total); v[i] <- add; total <- total - add; i <- i + 1L
    }
    scoreInstrument(berg, v)
  }
  expect_equal(at(20)@stratum, "high_fall_risk")      # upper bound of band 1
  expect_equal(at(21)@stratum, "medium_fall_risk")    # lower bound of band 2
  expect_equal(at(40)@stratum, "medium_fall_risk")    # upper bound of band 2
  expect_equal(at(41)@stratum, "low_fall_risk")       # lower bound of band 3
  expect_equal(at(56)@stratum, "low_fall_risk")       # maximum
  expect_equal(at(0)@stratum, "high_fall_risk")       # minimum
})

test_that("the registry loads bundled instruments and is extensible", {
  skip_if_not_installed("yaml")
  expect_true(all(c("berg", "fixture_ms") %in% listInstruments()))
  expect_s4_class(getInstrument("berg"), "ClinicalInstrument")
  expect_equal(length(getInstrument("berg")@items), 14L)
  expect_error(getInstrument("nope"), "No instrument")

  inst <- ClinicalInstrument(id = "reg_test", items = c("q"),
                             item_ranges = list(q = c(0, 5)))
  registerInstrument(inst)
  expect_true("reg_test" %in% listInstruments())
  expect_error(registerInstrument(inst), "already registered")
  expect_s4_class(registerInstrument(inst, overwrite = TRUE),
                  "ClinicalInstrument")
})

test_that("scoreInstrument resolves an instrument id via the registry", {
  skip_if_not_installed("yaml")
  sc <- scoreInstrument("berg", stats::setNames(rep(2, 14),
                                                getInstrument("berg")@items))
  expect_equal(sc@total, 28)
  expect_equal(sc@stratum, "medium_fall_risk")
})

test_that("unnamed responses map to the instrument's item order", {
  inst <- fixture_instrument()
  sc <- scoreInstrument(inst, c(2, 1, 2, 3, 2))
  expect_equal(sc@total, 10)
  expect_equal(sc@subscales[["motor"]], 5)
  expect_error(scoreInstrument(inst, c(2, 1, 2)), "one value per instrument item")
})

test_that("as.data.frame flattens a ClinicalScore", {
  inst <- fixture_instrument()
  df <- as.data.frame(scoreInstrument(inst, c(a1 = 2, a2 = 1, a3 = 2, b1 = 3, b2 = 2),
                                      subject_id = "s1"))
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 1L)
  expect_equal(df$total, 10)
  expect_equal(df$subject_id, "s1")
  expect_true(all(c("subscale_motor", "subscale_sensory") %in% names(df)))
})

test_that("instrument validity rejects malformed specifications", {
  expect_error(new("ClinicalInstrument", items = c("a", "a"),
                   item_ranges = list(a = c(0, 1))), "unique")
  expect_error(ClinicalInstrument(id = "x", items = "a",
                                  item_ranges = list(a = c(0, 1)),
                                  aggregation = "median"), "sum.*mean")
  expect_error(ClinicalInstrument(id = "x", items = "a",
                                  item_ranges = list(a = c(2, 1))), "min <= max")
})


# --- regression tests for adversarial-review findings ---

test_that("a fractional (prorated) total is classified into the nearest band", {
  skip_if_not_installed("yaml")
  berg <- getInstrument("berg")
  # 13 of 14 items observed summing to 19, one missing -> prorate 19*(14/13)=20.46
  v <- stats::setNames(c(4, 4, 4, 3, 2, 1, 1, 0, 0, 0, 0, 0, 0, NA), berg@items)
  sc <- scoreInstrument(berg, v, missing = "prorate")
  expect_true(sc@total > 20 && sc@total < 21)   # falls in the integer gap
  expect_equal(sc@stratum, "high_fall_risk")    # still classified, not NA
})

test_that("item_type given as a named vector maps to items by name", {
  inst <- ClinicalInstrument(
    id = "named_it", items = c("a", "b"),
    item_ranges = list(a = c(0, 10), b = c(0, 4)),
    item_type = c(b = "ordinal", a = "interval"))   # deliberately reordered
  expect_equal(inst@item_type, c("interval", "ordinal"))  # aligned to a, b
  expect_s4_class(scoreInstrument(inst, c(a = 1.5, b = 2)), "ClinicalScore")
  expect_error(scoreInstrument(inst, c(a = 1, b = 2.5)), "integer")
})

test_that("malformed responses are rejected, not silently coerced", {
  inst <- fixture_instrument()
  expect_error(scoreInstrument(inst, c(a1 = "x", a2 = 1, a3 = 2, b1 = 3, b2 = 2)),
               "numeric")
  # a factor is read by its labels, not its integer codes
  fv <- c(2, 1, 2, 3, 2)
  sc_num <- scoreInstrument(inst, fv)
  sc_fac <- scoreInstrument(inst, stats::setNames(
    factor(c("2", "1", "2", "3", "2")), inst@items))
  expect_equal(sc_fac@total, sc_num@total)
  # duplicated response names error
  expect_error(scoreInstrument(inst,
    stats::setNames(c(2, 1, 2, 3, 2), c("a1", "a1", "a3", "b1", "b2"))),
    "Duplicated")
})

test_that("the item_type length invariant is enforced at construction", {
  expect_error(ClinicalInstrument(id = "bad", items = c("a", "b", "c"),
    item_ranges = list(a = c(0, 1), b = c(0, 1), c = c(0, 1)),
    item_type = c("interval", "ordinal")), "one entry per item")
})

test_that("explicitly registering an invalid spec errors informatively", {
  skip_if_not_installed("yaml")
  bad <- tempfile(fileext = ".yaml")
  writeLines("id: broken\nname: no items here", bad)     # no items
  expect_error(registerInstrument(bad), "non-empty")
})

test_that("a malformed bundled spec is skipped, not fatal to the whole registry", {
  skip_if_not_installed("yaml")
  dir <- system.file("extdata", "instruments", package = "PhysioClinical")
  skip_if(dir == "" || !dir.exists(dir) || file.access(dir, 2) != 0)
  bad <- file.path(dir, "zz_bad_fixture.yaml")
  atomic <- file.path(dir, "zz_atomic_fixture.yaml")
  on.exit({ unlink(c(bad, atomic)) }, add = TRUE)
  writeLines("id: broken\nname: no items here", bad)      # parses, invalid
  writeLines("just a plain string", atomic)               # parses to an atomic

  reg <- PhysioClinical:::.registry()
  reg$instruments <- list(); reg$loaded <- FALSE
  # the bad specs are skipped (with a warning) and the good ones still load
  suppressWarnings(insts <- listInstruments())
  expect_true(all(c("berg", "fixture_ms") %in% insts))
  expect_false("broken" %in% insts)

  reg$instruments <- list(); reg$loaded <- FALSE
  unlink(c(bad, atomic))
  reg$instruments <- list(); reg$loaded <- FALSE
})
