# Interval (Rasch) analysis bridge: raschRecode() + raschAnalyze().

test_that("raschRecode maps weighted Barthel levels to consecutive categories", {
  items <- getInstrument("barthel")@items
  resp <- rbind(c(10, 5, 5, 10, 10, 10, 10, 15, 15, 10),   # fully independent
                c(0,  0, 0, 0,  0,  0,  0,  0,  0,  0),     # fully dependent
                c(5,  5, 0, 5,  5,  5,  5, 10,  5,  0))
  colnames(resp) <- items
  rc <- raschRecode("barthel", resp)
  # transfers/mobility have 4 categories (0..3); feeding etc. 3 (0..2); baths 2
  expect_equal(unname(rc[1, ]), c(2, 1, 1, 2, 2, 2, 2, 3, 3, 2))   # top category
  expect_true(all(rc[2, ] == 0))                                   # all lowest
  expect_equal(unname(rc[3, "transfers"]), 2L)                     # 10 -> cat 2
  # an out-of-vocabulary weight is rejected
  bad <- resp; bad[1, "feeding"] <- 7
  expect_error(raschRecode("barthel", bad), "admissible")
})

test_that("raschRecode requires all instrument items", {
  resp <- matrix(0, 2, 3, dimnames = list(NULL, c("feeding", "bathing", "x")))
  expect_error(raschRecode("barthel", resp), "missing column")
})

test_that("raschAnalyze recovers the Barthel item difficulty hierarchy", {
  skip_if_not_installed("PhysioAppKit")
  set.seed(2)
  items <- getInstrument("barthel")@items
  vals <- getInstrument("barthel")@item_values
  m <- c(2, 1, 1, 2, 2, 2, 2, 3, 3, 2)
  # designed difficulty: mobility/transfers/stairs hard, feeding/bathing easy
  true_loc <- c(feeding = -1.5, bathing = -1.2, grooming = -0.8,
                dressing = -0.3, bowels = 0.0, bladder = 0.2,
                toilet_use = 0.5, transfers = 1.0, mobility = 1.5,
                stairs = 0.8)
  N <- 350
  ability <- rnorm(N, 0, 1.5)
  resp <- matrix(NA_real_, N, length(items), dimnames = list(NULL, items))
  for (j in seq_along(items)) {
    thr <- true_loc[j] + seq(-0.6, 0.6, length.out = m[j])   # ordered steps
    for (p in seq_len(N)) {
      cat <- sum(ability[p] > thr + rnorm(m[j], 0, 0.5))
      resp[p, j] <- vals[[items[j]]][max(0, min(m[j], cat)) + 1]
    }
  }

  fit <- raschAnalyze("barthel", resp)
  expect_s3_class(fit, "clin_rasch")
  expect_equal(fit$instrument, "barthel")

  # item hierarchy is sorted hardest-first and recovers the designed order
  expect_equal(fit$item_hierarchy$item[1], names(which.max(true_loc)))  # mobility
  rho <- cor(fit$items$location, true_loc[fit$items$item], method = "spearman")
  expect_gt(rho, 0.85)

  # person separation reliability is usable and the analysed matrix is the recode
  expect_gt(fit$reliability$person_reliability, 0.7)
  expect_equal(fit$recoded, raschRecode("barthel", resp))

  # the bridge is a faithful pass-through of the engine
  direct <- PhysioAppKit::pcm_measure(raschRecode("barthel", resp), model = "PCM")
  expect_equal(fit$items$location, direct$items$location, tolerance = 1e-8)
})

test_that("Lawton IADL Rasch reduces to the dichotomous engine", {
  skip_if_not_installed("PhysioAppKit")
  set.seed(4)
  items <- getInstrument("lawton_iadl")@items
  loc <- seq(-1.5, 1.5, length.out = 8)
  ability <- rnorm(300, 0, 1.4)
  resp <- sapply(loc, function(d) as.integer(runif(300) < plogis(ability - d)))
  colnames(resp) <- items
  fit <- raschAnalyze("lawton_iadl", resp)
  ref <- PhysioAppKit::rasch_measure(resp)
  ok <- is.finite(ref$delta) & is.finite(fit$items$location)
  expect_gt(cor(ref$delta[ok], fit$items$location[ok]), 0.999)
})
