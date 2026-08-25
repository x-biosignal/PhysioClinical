# Batch cohort scoring -> interop-ready ClinicalScores.

test_that("scoreCohort produces subject-tagged scores that drive FHIR/OMOP", {
  items <- getInstrument("katz_adl")@items
  resp <- data.frame(
    subject_id = c("P01", "P02"),
    stats::setNames(as.data.frame(rbind(rep(1, 6), c(1, 0, 1, 1, 0, 1))), items),
    stringsAsFactors = FALSE)

  scores <- scoreCohort(resp, "katz_adl")
  expect_length(scores, 2L)
  expect_named(scores, c("P01", "P02"))
  expect_s4_class(scores[["P01"]], "ClinicalScore")
  expect_equal(scores[["P01"]]@subject_id, "P01")
  expect_equal(scores[["P01"]]@total, 6)          # all independent
  expect_equal(scores[["P02"]]@total, 4)

  # drives the existing FHIR exporter directly (subject ref from subject_id)
  path <- tempfile(fileext = ".json")
  writeFHIRBundle(scores, path)
  expect_true(file.exists(path))

  # and the OMOP exporter (integer person ids via a map; the concept-map notice
  # is toOMOP's documented behaviour when no site concept_map is supplied)
  expect_warning(
    omop <- toOMOP(scores, person_map = c(P01 = 1L, P02 = 2L)),
    "concept_id")
  expect_true(is.list(omop) || is.data.frame(omop))

  expect_error(scoreCohort(resp, "katz_adl", subject_col = "nope"),
               "subject column")
})

test_that("scoreCohort prorates when only some items are present", {
  # a partial response table (3 of 6 Katz items) scored with proration
  resp <- data.frame(subject_id = "P03", bathing = 1, dressing = 1, feeding = 1)
  scores <- scoreCohort(resp, "katz_adl", missing = "prorate")
  expect_equal(scores[["P03"]]@subject_id, "P03")
  expect_equal(scores[["P03"]]@total, 6)          # 3/3 -> prorated to 6
})
