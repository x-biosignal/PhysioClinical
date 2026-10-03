library(testthat)
library(PhysioClinical)

test_that("FMA-LE reproduces a worked-example total and subscales", {
  skip_if_not_installed("yaml")
  fl <- getInstrument("fma_le")
  expect_equal(length(fl@items), 17L)
  full <- scoreFMALE(stats::setNames(rep(2, 17), fl@items))
  expect_equal(full@total, 34)
  expect_equal(unname(full@subscales[c("motor", "coordination_speed")]),
               c(28, 6))
  # a partial example: motor 20, coordination 4 -> 24
  v <- stats::setNames(rep(0, 17), fl@items)
  v[fl@subscales$motor[1:10]] <- 2                    # 20
  v[fl@subscales$coordination_speed[1:2]] <- 2        # 4
  sc <- scoreFMALE(v)
  expect_equal(sc@total, 24)
  expect_equal(sc@subscales[["motor"]], 20)
  expect_equal(sc@subscales[["coordination_speed"]], 4)
})

test_that("Berg (BBS) total and fall-risk strata cut at the boundaries", {
  skip_if_not_installed("yaml")
  berg <- getInstrument("berg")
  expect_equal(length(berg@items), 14L)
  at <- function(total) {
    v <- stats::setNames(rep(0, 14), berg@items); i <- 1L
    while (total > 0) { a <- min(4, total); v[i] <- a; total <- total - a; i <- i + 1L }
    scoreBerg(v)
  }
  expect_equal(at(56)@total, 56)
  expect_equal(at(20)@stratum, "high_fall_risk")      # 0-20
  expect_equal(at(21)@stratum, "medium_fall_risk")    # 21-40
  expect_equal(at(40)@stratum, "medium_fall_risk")
  expect_equal(at(41)@stratum, "low_fall_risk")       # 41-56
})

test_that("FIM reproduces published totals and motor/cognitive subscale sums", {
  skip_if_not_installed("yaml")
  fim <- getInstrument("fim")
  expect_equal(length(fim@items), 18L)
  # complete independence (all 7) and complete dependence (all 1)
  indep <- scoreFIM(stats::setNames(rep(7, 18), fim@items))
  expect_equal(indep@total, 126)
  expect_equal(indep@subscales[["motor"]], 91)        # 13 items x 7
  expect_equal(indep@subscales[["cognitive"]], 35)    # 5 items x 7
  expect_equal(scoreFIM(stats::setNames(rep(1, 18), fim@items))@total, 18)
  # the six domains partition; motor + cognitive overlap them but do not
  # double-count the total
  domains <- c("self_care", "sphincter", "transfers", "locomotion",
               "communication", "social_cognition")
  expect_equal(indep@total, sum(indep@subscales[domains]))
  expect_equal(indep@subscales[["motor"]],
               sum(indep@subscales[c("self_care", "sphincter", "transfers",
                                     "locomotion")]))
  expect_equal(indep@subscales[["cognitive"]],
               sum(indep@subscales[c("communication", "social_cognition")]))
  # a mixed worked example
  v <- stats::setNames(rep(5, 18), fim@items)
  v[c("eating", "grooming")] <- 7; v[c("memory")] <- 3
  sc <- scoreFIM(v)
  expect_equal(sc@total, 5 * 18 + 2 * 2 - 2)          # 90 + 4 - 2 = 92
})

test_that("FAM reproduces totals and the motor/cognitive split", {
  skip_if_not_installed("yaml")
  fam <- getInstrument("fam")
  expect_equal(length(fam@items), 30L)
  full <- scoreFAM(stats::setNames(rep(7, 30), fam@items))
  expect_equal(full@total, 210)
  expect_equal(unname(full@subscales[c("motor", "cognitive")]), c(112, 98))
  expect_equal(scoreFAM(stats::setNames(rep(1, 30), fam@items))@total, 30)
  # total = sum of the (partitioning) motor + cognitive subscales
  expect_equal(full@total, sum(full@subscales))
})

test_that("proration on FIM keeps the total independent of the overlap", {
  skip_if_not_installed("yaml")
  fim <- getInstrument("fim")
  v <- stats::setNames(rep(7, 18), fim@items); v["eating"] <- NA
  sc <- scoreFIM(v, missing = "prorate")
  # 17 of 18 observed, each 7 -> prorated total 7 * 18 = 126, not double-counted
  expect_equal(sc@total, 7 * 18)
})

test_that("overlapping subscales do not double-count the total (WS7-02 fix)", {
  inst <- ClinicalInstrument(
    id = "ov", items = c("a", "b", "c"),
    item_ranges = list(a = c(0, 5), b = c(0, 5), c = c(0, 5)),
    aggregation = "sum",
    subscales = list(motor = c("a", "b", "c"), sub1 = c("a", "b"),
                     sub2 = c("c")))
  sc <- scoreInstrument(inst, c(a = 1, b = 2, c = 3))
  expect_equal(sc@total, 6)                            # not 12
  expect_equal(sc@subscales[["motor"]], 6)
  expect_equal(sc@subscales[["sub1"]], 3)
  expect_equal(sc@subscales[["sub2"]], 3)
})

test_that("the mobility wrappers delegate to their registered instruments", {
  skip_if_not_installed("yaml")
  expect_equal(scoreFMALE(stats::setNames(rep(0, 17),
    getInstrument("fma_le")@items))@instrument_id, "fma_le")
  expect_equal(scoreBerg(stats::setNames(rep(0, 14),
    getInstrument("berg")@items))@instrument_id, "berg")
  expect_equal(scoreFIM(stats::setNames(rep(1, 18),
    getInstrument("fim")@items))@instrument_id, "fim")
  expect_equal(scoreFAM(stats::setNames(rep(1, 30),
    getInstrument("fam")@items))@instrument_id, "fam")
})
