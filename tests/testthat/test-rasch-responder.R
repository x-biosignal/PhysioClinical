# Responder analysis on the Rasch interval scale (raschResponder): wires the
# interval measures into the existing mdcResponder / classifyResponder.

test_that("reliable change on the logit scale matches mdcResponder", {
  pre  <- list(theta = c(0, 0, 0, 0), theta_se = rep(0.3, 4))
  post <- list(theta = c(1.5, 0.1, -1.2, 0.05), theta_se = rep(0.3, 4))
  r <- raschResponder(pre, post)
  sem <- sqrt(mean(rep(0.3, 8)^2))                 # 0.3
  expect_equal(attr(r, "sem"), sem)
  expect_equal(r$reliable_change,
               mdcResponder(post$theta - pre$theta, sem))
  # MDC = 1.96*sqrt(2)*0.3 ~ 0.83: +1.5 improved, +/-0.1 stable, -1.2 declined
  expect_equal(r$reliable_change, c("improved", "stable", "declined", "stable"))
})

test_that("MCID path reproduces classifyResponder on the interval measures", {
  pre  <- list(theta = c(0, 0.2, -0.5, 1.0), theta_se = rep(0.25, 4))
  post <- list(theta = c(1.6, 0.3, 1.0, 1.1), theta_se = rep(0.25, 4))
  r <- raschResponder(pre, post, mcid = 1.0)
  mdc_val <- attr(r, "mdc")
  ref <- classifyResponder(pre$theta, post$theta, mdc = mdc_val, mcid = 1.0,
                           direction = "increase")
  expect_equal(as.character(r$classification), as.character(ref$classification))
  expect_true("true_responder" %in% as.character(r$classification))
})

test_that("direction = decrease flips improvement", {
  pre  <- list(theta = c(2, 2), theta_se = rep(0.2, 2))
  post <- list(theta = c(0, 4), theta_se = rep(0.2, 2))
  r <- raschResponder(pre, post, direction = "decrease")
  expect_equal(r$improvement, c(2, -2))            # lower is better (-change)
  expect_equal(r$reliable_change, c("improved", "declined"))
})

test_that("accepts real poly_rasch fits and needs SEs", {
  skip_if_not_installed("PhysioAppKit")
  set.seed(5)
  mk <- function(shift) {
    ability <- rnorm(150, shift, 1)
    x <- sapply(seq(-1.2, 1.2, length.out = 8), function(d)
      pmax(0L, pmin(2L, as.integer(round(ability - d + rnorm(150))))))
    PhysioAppKit::pcm_measure(x)
  }
  fit_pre <- mk(0); fit_post <- mk(0.8)            # cohort improves ~0.8 logit
  r <- raschResponder(fit_pre, fit_post)
  expect_equal(nrow(r), 150)
  expect_true(mean(r$change, na.rm = TRUE) > 0)     # net improvement
  expect_true(all(r$reliable_change %in% c("improved", "stable", "declined")))
  # a bare numeric measure vector has no SE -> informative error
  expect_error(raschResponder(fit_pre$theta, fit_post$theta), "standard errors")
})
