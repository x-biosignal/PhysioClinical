# Score crosswalks (equateScores / applyEquating).

test_that("linear equating recovers an exact linear relationship", {
  set.seed(1)
  from <- rnorm(300, 50, 12)
  to <- 3 + 1.5 * from                       # exact linear map
  eq <- equateScores(from, to, method = "linear")
  expect_equal(applyEquating(eq, c(40, 60, 80)), 3 + 1.5 * c(40, 60, 80),
               tolerance = 1e-6)
})

test_that("equipercentile equating preserves percentile ranks", {
  set.seed(2)
  from <- round(rnorm(500, 60, 15))
  to <- round(80 + 20 * ((from - 60) / 15) + rnorm(500, 0, 2))  # monotone-ish
  eq <- equateScores(from, to)
  # a source value at the ~50th percentile maps near the target median
  med_from <- median(from)
  expect_equal(applyEquating(eq, med_from), median(to), tolerance = 4)
  # the crosswalk is monotone non-decreasing
  expect_true(all(diff(eq$table$to) >= -1e-8))
})

test_that("Barthel<->FIM crosswalk from a shared-ability linking sample", {
  set.seed(3)
  ability <- rnorm(400)
  barthel <- pmin(100, pmax(0, round((ability + 3) * 16 / 5) * 5))   # 0-100
  fim <- pmin(126, pmax(18, round(18 + (ability + 3) * 18)))         # 18-126

  b2f <- equateScores(barthel, fim)                # Barthel -> FIM
  f2b <- equateScores(fim, barthel)                # FIM -> Barthel
  expect_s3_class(b2f, "score_equating")
  # higher Barthel maps to higher FIM (monotone)
  expect_true(all(diff(b2f$table$to) >= -1e-8))
  # FIM equivalents stay within the FIM range
  expect_true(all(b2f$table$to >= 18 & b2f$table$to <= 126))
  # round-trip Barthel -> FIM -> Barthel is close to the identity mid-range
  mid <- c(40, 60, 80)
  rt <- applyEquating(f2b, applyEquating(b2f, mid))
  expect_lt(max(abs(rt - mid)), 12)
})

test_that("equateScores validates input", {
  expect_error(equateScores(1, c(2, 3)), "at least two")
})
