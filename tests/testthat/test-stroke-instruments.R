library(testthat)
library(PhysioClinical)

# Build a named response vector for an instrument from per-subscale totals,
# distributing each subscale total across its items (each capped at the item
# max), so the resulting total and subscales are exactly known.
fill_subscales <- function(inst, subscale_totals) {
  v <- stats::setNames(rep(0, length(inst@items)), inst@items)
  for (nm in names(subscale_totals)) {
    items <- inst@subscales[[nm]]
    remaining <- subscale_totals[[nm]]
    for (it in items) {
      cap <- inst@item_ranges[[it]][2]
      add <- min(cap, remaining)
      v[it] <- add; remaining <- remaining - add
    }
    if (remaining != 0) stop("subscale total exceeds its item capacity")
  }
  v
}

test_that("FMA-UE reproduces a worked-example total and subscales", {
  skip_if_not_installed("yaml")
  fma <- getInstrument("fma_ue")
  # A=20, wrist=6, hand=8, coordination=4 -> total 38 (moderate)
  v <- fill_subscales(fma, list(shoulder_elbow_forearm = 20, wrist = 6,
                                hand = 8, coordination_speed = 4))
  sc <- scoreFMAUE(v)
  expect_equal(sc@total, 38)
  expect_equal(unname(sc@subscales[c("shoulder_elbow_forearm", "wrist",
                                     "hand", "coordination_speed")]),
               c(20, 6, 8, 4))
  expect_equal(sc@stratum, "moderate")
  # full and empty extremes
  expect_equal(scoreFMAUE(stats::setNames(rep(2, 33), fma@items))@total, 66)
  expect_equal(scoreFMAUE(stats::setNames(rep(0, 33), fma@items))@stratum,
               "severe")
})

test_that("FMA-UE strata cut at 25/26 and 52/53 (Woodbury)", {
  skip_if_not_installed("yaml")
  fma <- getInstrument("fma_ue")
  at <- function(total) {
    v <- stats::setNames(rep(0, 33), fma@items); i <- 1L
    while (total > 0) { a <- min(2, total); v[i] <- a; total <- total - a; i <- i + 1L }
    scoreFMAUE(v)@stratum
  }
  expect_equal(at(25), "severe")
  expect_equal(at(26), "moderate")
  expect_equal(at(52), "moderate")
  expect_equal(at(53), "mild")
})

test_that("ARAT reproduces a worked-example total and subscales", {
  skip_if_not_installed("yaml")
  ar <- getInstrument("arat")
  v <- fill_subscales(ar, list(grasp = 10, grip = 8, pinch = 12,
                               gross_movement = 6))
  sc <- scoreARAT(v)
  expect_equal(sc@total, 36)
  expect_equal(unname(sc@subscales[c("grasp", "grip", "pinch",
                                     "gross_movement")]), c(10, 8, 12, 6))
  expect_equal(scoreARAT(stats::setNames(rep(3, 19), ar@items))@total, 57)
})

test_that("NIHSS reproduces a total and its severity band cuts", {
  skip_if_not_installed("yaml")
  ni <- getInstrument("nihss")
  z <- stats::setNames(rep(0, 15), ni@items)
  # a moderate example summing to 10
  ex <- z; ex[c("loc", "gaze", "left_arm", "language")] <- c(1, 2, 4, 3)
  expect_equal(scoreNIHSS(ex)@total, 10)
  expect_equal(scoreNIHSS(ex)@stratum, "moderate")
  band <- function(total) {
    v <- z; r <- total
    for (it in ni@items) {                                  # fill greedily
      cap <- ni@item_ranges[[it]][2]; add <- min(cap, r)
      v[it] <- add; r <- r - add
      if (r <= 0) break
    }
    scoreNIHSS(v)@stratum
  }
  expect_equal(scoreNIHSS(z)@stratum, "no_stroke")          # 0
  expect_equal(band(4), "minor")                            # 1-4
  expect_equal(band(5), "moderate")                         # 5-15
  expect_equal(band(16), "moderate_to_severe")              # 16-20
  expect_equal(band(21), "severe")                          # 21-42
})

test_that("mRS maps each grade to its disability band", {
  skip_if_not_installed("yaml")
  labels <- c("no_symptoms", "no_significant_disability", "slight_disability",
              "moderate_disability", "moderately_severe_disability",
              "severe_disability", "dead")
  for (g in 0:6) {
    sc <- scoreMRS(g)
    expect_equal(sc@total, g)
    expect_equal(sc@stratum, labels[g + 1L])
  }
  expect_error(scoreMRS(7), "outside its range")
})

test_that("MAS handles the '1+' level arithmetically and round-trips its label", {
  skip_if_not_installed("yaml")
  expect_equal(scoreMAS("1+")@total, 1.5)
  expect_equal(scoreMAS("0")@total, 0)
  expect_equal(scoreMAS(2)@total, 2)                        # numeric input
  expect_equal(scoreMAS("4")@total, 4)
  # the numeric value round-trips to the ordinal label
  expect_equal(masLevelLabel(1.5), "1+")
  expect_equal(masLevelLabel(scoreMAS("1+")@total), "1+")
  expect_equal(masLevelLabel(c(0, 1, 1.5, 2, 3, 4)),
               c("0", "1", "1+", "2", "3", "4"))
  expect_error(scoreMAS("5"), "Invalid MAS level")
  expect_error(scoreMAS("1.25"), "Invalid MAS level")
})

test_that("WMFT-FAS is the mean functional-ability score and time is the median", {
  skip_if_not_installed("yaml")
  wm <- getInstrument("wmft_fas")
  fas <- stats::setNames(c(rep(5, 10), rep(0, 5)), wm@items)
  expect_equal(scoreWMFT(fas)@total, 50 / 15)
  expect_equal(wmftMedianTime(c(2, 4, 6, 8, 10)), 6)
  expect_equal(wmftMedianTime(c(3, 1, 2)), 2)
})

test_that("the wrappers all delegate to their registered instruments", {
  skip_if_not_installed("yaml")
  expect_equal(scoreFMAUE(stats::setNames(rep(0, 33),
    getInstrument("fma_ue")@items))@instrument_id, "fma_ue")
  expect_equal(scoreARAT(stats::setNames(rep(0, 19),
    getInstrument("arat")@items))@instrument_id, "arat")
  expect_equal(scoreNIHSS(stats::setNames(rep(0, 15),
    getInstrument("nihss")@items))@instrument_id, "nihss")
  expect_equal(scoreMRS(0)@instrument_id, "mrs")
  expect_equal(scoreMAS("0")@instrument_id, "mas")
  expect_equal(scoreWMFT(stats::setNames(rep(0, 15),
    getInstrument("wmft_fas")@items))@instrument_id, "wmft_fas")
})


# --- regression test for adversarial-review finding ---

test_that("the MAS discrete level set is enforced on the generic engine too", {
  skip_if_not_installed("yaml")
  # the wrapper already guards, but the generic path must also reject non-levels
  expect_error(scoreInstrument("mas", c(muscle = 2.5)), "not an allowed level")
  expect_error(scoreInstrument("mas", c(muscle = 3.7)), "not an allowed level")
  # the valid MAS levels (including 1+ = 1.5) still pass
  for (v in c(0, 1, 1.5, 2, 3, 4)) {
    expect_equal(scoreInstrument("mas", c(muscle = v))@total, v)
  }
  # instruments without item_values are unaffected
  expect_equal(scoreInstrument("berg", stats::setNames(
    rep(2, 14), getInstrument("berg")@items))@total, 28)
})
