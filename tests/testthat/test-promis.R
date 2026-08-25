# PROMIS / graded-response-model EAP scoring.

# simulate one GRM response (category 1..K) at latent theta
.sim_grm <- function(theta, a, b) {
  K <- length(b) + 1L
  pstar <- c(1, stats::plogis(a * (theta - b)), 0)
  p <- pstar[seq_len(K)] - pstar[seq_len(K) + 1L]
  sample.int(K, 1L, prob = p)
}

test_that("scorePROMIS EAP recovers the latent trait (GRM simulation)", {
  set.seed(42)
  ni <- 20
  cal <- data.frame(item = paste0("i", seq_len(ni)),
                    a = runif(ni, 1.5, 3),
                    b1 = runif(ni, -2.0, -1.1), b2 = runif(ni, -1.0, -0.1),
                    b3 = runif(ni,  0.1,  1.0), b4 = runif(ni,  1.1,  2.0))
  thetas <- rnorm(80)
  est <- vapply(thetas, function(th) {
    resp <- vapply(seq_len(ni), function(j)
      .sim_grm(th, cal$a[j], as.numeric(unlist(cal[j, c("b1","b2","b3","b4")]))),
      integer(1))
    names(resp) <- cal$item
    scorePROMIS(resp, cal)$theta
  }, numeric(1))
  expect_gt(stats::cor(est, thetas), 0.9)
})

test_that("scorePROMIS is monotone and on the T-score metric", {
  cal <- data.frame(item = c("i1","i2","i3","i4"), a = c(2.4,1.9,2.7,2.1),
    b1 = c(-2,-1.5,-1.8,-1.6), b2 = c(-1,-0.5,-0.7,-0.6),
    b3 = c(0.2,0.1,0,0.1), b4 = c(1.4,1.2,1.1,1.3))
  lo <- scorePROMIS(stats::setNames(rep(1, 4), cal$item), cal)
  hi <- scorePROMIS(stats::setNames(rep(5, 4), cal$item), cal)
  expect_lt(lo$theta, hi$theta)
  mid <- scorePROMIS(stats::setNames(rep(3, 4), cal$item), cal)
  expect_equal(mid$tscore, 50 + 10 * mid$theta)
  expect_equal(mid$se_tscore, 10 * mid$se_theta)
  expect_gt(mid$se_theta, 0)
  expect_equal(mid$n_items, 4L)
  # a skipped (NA) item is dropped, not an error
  expect_equal(scorePROMIS(c(i1 = 4, i2 = NA, i3 = 5, i4 = NA), cal)$n_items, 2L)
})

test_that("scorePROMIS validates responses and calibration", {
  cal <- data.frame(item = "i1", a = 2, b1 = -1, b2 = 0, b3 = 1, b4 = 2) # K=5
  expect_error(scorePROMIS(c(i1 = 6), cal), "outside 1..5")
  expect_error(scorePROMIS(stats::setNames(NA_real_, "i1"), cal), "no non-missing")
  expect_error(scorePROMIS(c(i1 = 3), data.frame(item = "i1", a = 2)),
               "threshold columns")
})

test_that("promisRawToT looks up a supplied conversion table", {
  tab <- data.frame(raw = 4:8, tscore = c(21.5, 30.1, 35.7, 40.2, 44.0),
                    se = c(5, 4, 3.5, 3.3, 3.2))
  expect_equal(promisRawToT(6, tab)$tscore, 35.7)
  expect_equal(promisRawToT(6, tab)$se, 3.5)
  expect_warning(r <- promisRawToT(99, tab), "not in the conversion table")
  expect_true(is.na(r$tscore))
})
