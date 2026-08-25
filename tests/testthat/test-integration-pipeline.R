# WS7-16: end-to-end pipeline + cross-package integration.

test_that("the score -> classify -> GAS -> FHIR pipeline runs on a fixture", {
  bl_items <- setNames(c(4, 3, 4, 3, 2, 3, 2, 2, 3, 2, 1, 2, 1, 1),
                       sprintf("item%02d", 1:14))
  fu_items <- setNames(c(4, 4, 4, 4, 3, 4, 3, 3, 4, 3, 3, 3, 2, 3),
                       sprintf("item%02d", 1:14))
  bl <- scoreInstrument("berg", bl_items, subject_id = "P001")
  fu <- scoreInstrument("berg", fu_items, subject_id = "P001")
  expect_s4_class(bl, "ClinicalScore")
  expect_equal(fu@total, 47)
  expect_true(fu@total > bl@total)

  # dual responder classification on a store instrument with both MDC and MCID
  # (FMA-UE minimal: MDC 6.65 > MCID 4.25, so the dual rule is non-trivial)
  rc <- classifyResponder(baseline = 30, followup = 39, instrument = "FMA-UE",
                          population = "chronic_stroke_minimal",
                          direction = "increase")
  expect_equal(as.character(rc$classification), "true_responder")
  # a change past the MCID but inside the MDC is only measurement error
  me <- classifyResponder(baseline = 30, followup = 36, instrument = "FMA-UE",
                          population = "chronic_stroke_minimal",
                          direction = "increase")
  expect_equal(as.character(me$classification), "measurement_error")

  # goal attainment
  goals <- list(defineGoal("Balance", importance = 3, difficulty = 2),
                defineGoal("Walk 10 m", importance = 3, difficulty = 3))
  gas <- scoreGAS(goals, attained_levels = c(1, 0))
  expect_s3_class(gas, "gas_result")

  # FHIR export closes the pipeline
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("jsonvalidate")
  obs <- toFHIRObservation(fu)
  expect_equal(obs$resourceType, "Observation")
  expect_true(validateFHIRObservation(obs))
})

test_that("PhysioClinical and PhysioAnnotationHub integrate for ICF tagging", {
  skip_if_not_installed("PhysioAnnotationHub")
  sc <- scoreInstrument("berg",
                        setNames(rep(3L, 14), sprintf("item%02d", 1:14)),
                        subject_id = "P002")
  # the scored instrument's id links to WHO ICF categories
  icf <- PhysioAnnotationHub::tagICF(sc@instrument_id)
  expect_true(length(icf) >= 1L)
  expect_true(all(grepl("^[bsde][0-9]", icf)))
  # a published Core Set is available for the same patient's condition
  cs <- PhysioAnnotationHub::getCoreSet("Stroke")
  expect_true(nrow(cs) >= 1L)
  expect_true("category_title" %in% names(cs))
})

test_that("the clinimetric store reproduces >=3 published reference values", {
  anchors <- list(
    c(inst = "BBS",    stat = "MDC",         pop = "elderly_baseline_45_56",  exp = "3.30"),
    c(inst = "FMA-UE", stat = "MCID_anchor", pop = "chronic_stroke_minimal",  exp = "4.25"),
    c(inst = "6MWT",   stat = "MCID_dist",   pop = "older_adults",            exp = "20"),
    c(inst = "FIM",    stat = "MCID_anchor", pop = "stroke",                  exp = "22"))
  ok <- vapply(anchors, function(a) {
    got <- getClinimetric(a[["inst"]], a[["stat"]], population = a[["pop"]])
    value <- if (is.data.frame(got)) got$value[1] else got
    is.finite(value) && abs(value - as.numeric(a[["exp"]])) <= 0.5
  }, logical(1))
  expect_gte(sum(ok), 3L)
  expect_true(all(ok))
})
