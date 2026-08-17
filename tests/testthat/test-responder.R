test_that("mdcResponder classifies against the MDC threshold", {
  # sem=1.5 -> MDC = qnorm(0.975)*sqrt(2)*1.5 ~= 4.157
  r <- mdcResponder(c(5, 0.5, -6), sem_value = 1.5)
  expect_equal(r, c("improved", "stable", "declined"))
  expect_equal(mdcResponder(0, sem_value = 1), "stable")
})
