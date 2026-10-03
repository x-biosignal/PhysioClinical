test_that("distribution MDC equals 1.96*sqrt(2)*SEM and matches PhysioCore::mdc", {
  set.seed(1)
  base <- rnorm(60, 50, 10)
  retest <- base + rnorm(60, 0, 3)
  e <- estimateMDC(cbind(base, retest))
  z <- stats::qnorm(0.975)
  expect_equal(e$mdc, z * sqrt(2) * e$sem, tolerance = 1e-12)
  expect_equal(e$mdc, PhysioCore::mdc(e$sem, 0.95), tolerance = 1e-12)
  # SEM = SD * sqrt(1 - ICC)
  expect_equal(e$sem, stats::sd(as.numeric(cbind(base, retest))) *
                 sqrt(1 - e$icc), tolerance = 1e-12)
  expect_error(estimateMDC(base), "matrix")            # needs >= 2 columns
})

test_that("a negative ICC is clamped (not an opaque sem error)", {
  m <- matrix(c(1, 2, 3, 3, 2, 1), ncol = 2)   # anti-correlated -> ICC < 0
  expect_warning(e <- estimateMDC(m), "clamping")
  expect_equal(e$icc, 0)
  expect_true(is.finite(e$mdc) && e$mdc > 0)
})

test_that("distribution MCID is a fraction of the baseline SD", {
  expect_equal(estimateMCID_distribution(12), 6)
  expect_equal(estimateMCID_distribution(12, fraction = 0.2), 2.4)
  expect_error(estimateMCID_distribution(-1), "non-negative")
  expect_error(estimateMCID_distribution(10, fraction = 0), "positive")
})

test_that("anchor ROC MCID recovers a planted cut via the Youden index", {
  set.seed(3)
  truecut <- 5
  change <- runif(400, -2, 12)
  anchor <- as.integer(change >= truecut)
  roc <- estimateMCID_anchor(change, anchor, method = "roc")
  expect_lt(abs(roc - truecut), 1)
  # mean-change and predictive also return sane change-scale estimates
  mc <- estimateMCID_anchor(change, anchor, method = "mean_change")
  expect_gt(mc, truecut)                    # mean of the improved (>= cut)
  expect_silent(estimateMCID_anchor(change, anchor, method = "predictive"))
})

test_that("anchor MCID is direction-aware and validates inputs", {
  # decrease-is-good: lower change means improvement; the cut is on the change
  # scale (negative), recovered from a planted separation
  set.seed(4)
  change <- runif(400, -12, 2)
  anchor <- as.integer(change <= -5)        # improved = big negative change
  roc <- estimateMCID_anchor(change, anchor, method = "roc",
                             direction = "decrease")
  expect_lt(abs(roc - (-5)), 1)
  expect_error(estimateMCID_anchor(1:3, c(0, 1)), "same length")
  expect_error(estimateMCID_anchor(c(1, 2), c(0, 0), method = "roc"),
               "both improved")
})
