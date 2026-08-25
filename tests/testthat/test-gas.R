test_that("all goals at the expected level give T = 50", {
  g1 <- defineGoal("Transfers", importance = 3, difficulty = 2)
  g2 <- defineGoal("Stairs", importance = 2, difficulty = 3)
  expect_equal(scoreGAS(list(g1, g2), c(0, 0))$t_score, 50)
  # a single unweighted goal one level above expected is exactly 1 SD (T = 60)
  expect_equal(scoreGAS(defineGoal("g"), 1)$t_score, 60)
  expect_equal(scoreGAS(defineGoal("g"), -1)$t_score, 40)
})

test_that("the weighted T-score matches a hand calculation", {
  # two goals, weight = importance*difficulty = 6 each, attained (1, 0), rho 0.3
  # num = 10*(6*1 + 6*0) = 60
  # den = sqrt(0.7*(36+36) + 0.3*(12)^2) = sqrt(93.6)
  r <- scoreGAS(list(defineGoal("a", importance = 3, difficulty = 2),
                     defineGoal("b", importance = 3, difficulty = 2)),
                c(1, 0))
  expect_equal(r$t_score, 50 + 60 / sqrt(0.7 * 72 + 0.3 * 144),
               tolerance = 1e-9)
  expect_true(r$weighted)

  # unweighted two goals both +1
  ru <- scoreGAS(list(defineGoal("a"), defineGoal("b")), c(1, 1))
  expect_equal(ru$t_score, 50 + 20 / sqrt(2.6), tolerance = 1e-9)
  expect_false(ru$weighted)

  # rho changes the denominator
  r0 <- scoreGAS(list(defineGoal("a"), defineGoal("b")), c(1, 1), rho = 0)
  expect_equal(r0$t_score, 50 + 20 / sqrt(2), tolerance = 1e-9)
})

test_that("defineGoal and scoreGAS validate their inputs", {
  expect_error(defineGoal("g", levels = c(1, 2, 3)), "including 0")
  expect_error(defineGoal("g", weight = 0), "positive")
  expect_error(defineGoal("g", importance = -1, difficulty = 2), "non-negative")
  # only one of importance/difficulty warns (weighting needs both)
  expect_warning(defineGoal("g", importance = 3), "both")
  expect_warning(defineGoal("g", difficulty = 2), "both")
  expect_error(scoreGAS(defineGoal("g"), 3), "outside goal")   # level range
  expect_error(scoreGAS(list(defineGoal("g")), c(0, 1)), "one value per goal")
  expect_error(scoreGAS(list(defineGoal("g")), NA), "NA")
  expect_error(scoreGAS(list(defineGoal("g")), 0, rho = 1), "\\[0, 1\\)")
  expect_error(scoreGAS(list(1), 0), "gas_goal")
})

test_that("gasSummary tabulates goals with ICF tags and contributions", {
  r <- scoreGAS(list(defineGoal("Walk", importance = 3, difficulty = 2,
                                icf_tag = "d450"),
                     defineGoal("Grip")), c(2, -1))
  s <- gasSummary(r)
  expect_equal(nrow(s), 2L)
  expect_equal(s$icf_tag, c("d450", NA_character_))
  expect_equal(s$contribution, s$weight * s$attained)
  expect_equal(attr(s, "t_score"), r$t_score)
  expect_output(print(r), "gas_result")
  expect_output(print(r), "Walk")
})
