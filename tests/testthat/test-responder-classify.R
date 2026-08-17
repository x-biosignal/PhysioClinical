test_that("the 4-cell dual classification truth table is correct (increase)", {
  # improvements: 11 (both), 6 (>MDC only), 7 (>MCID only; mcid<mdc), 2 (neither)
  r <- classifyResponder(
    baseline = c(0, 0, 0, 0), followup = c(11, 6, 7, 2),
    mdc = 5, mcid = 10, direction = "increase")
  # with mdc=5, mcid=10: 11->both, 6->mdc-only, 7->mdc-only, 2->neither
  expect_equal(as.character(r$classification),
               c("true_responder", "subclinical_change", "subclinical_change",
                 "non_responder"))

  # the measurement_error cell only exists when MCID < MDC
  me <- classifyResponder(0, 7, mdc = 10, mcid = 5)   # imp 7: >=mcid, <mdc
  expect_equal(as.character(me$classification), "measurement_error")
  full <- classifyResponder(c(0, 0, 0, 0), c(12, 7, 3, -1), mdc = 10, mcid = 5)
  expect_equal(as.character(full$classification),
               c("true_responder", "measurement_error", "non_responder",
                 "non_responder"))
})

test_that("classification is direction-aware (decrease is good)", {
  # lower follow-up is improvement; drops of 11/6/1 with mdc=5, mcid=10
  r <- classifyResponder(c(20, 20, 20), c(9, 14, 19), mdc = 5, mcid = 10,
                         direction = "decrease")
  expect_equal(as.character(r$classification),
               c("true_responder", "subclinical_change", "non_responder"))
  # the same raw change is a non-responder for an increase-is-good metric
  r_inc <- classifyResponder(c(20), c(9), mdc = 5, mcid = 10,
                             direction = "increase")
  expect_equal(as.character(r_inc$classification), "non_responder")
})

test_that("thresholds are looked up from the clinimetric store when omitted", {
  # FMA-UE chronic_stroke_minimal: MCID_anchor = 4.25 (from the store)
  r <- classifyResponder(20, 31, instrument = "FMA-UE",
                         population = "chronic_stroke_minimal", mdc = 5.2)
  expect_equal(r$mcid[1], 4.25)
  # an ambiguous instrument (multiple populations, no population given) errors
  expect_error(
    classifyResponder(20, 31, instrument = "FMA-UE", mdc = 5.2),
    "specify a population")
  expect_error(classifyResponder(20, 31), "instrument")
})

test_that("summary is the MDC x MCID contingency table and print works", {
  r <- classifyResponder(c(0, 0, 0, 0), c(11, 6, 3, 12), mdc = 5, mcid = 10)
  tab <- summary(r)
  expect_s3_class(tab, "table")
  expect_equal(sum(tab), 4L)
  expect_output(print(r), "responder_classification")
  expect_output(print(r), "true_responder")
  expect_error(classifyResponder(1:3, 1:2, mdc = 1, mcid = 2), "same length")
  expect_error(classifyResponder(1, 2, mdc = -1, mcid = 2), "positive")
})

test_that("a missing (dropout) subject is NA-classified and still counted", {
  r <- classifyResponder(c(20, 20), c(31, NA), mdc = 5, mcid = 10)
  expect_true(is.na(r$classification[2]))
  # useNA keeps the contingency table summing to N
  expect_equal(sum(summary(r)), 2L)
})
