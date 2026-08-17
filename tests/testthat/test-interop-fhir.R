make_score <- function() {
  methods::new("ClinicalScore", instrument_id = "fim", total = 100,
               subscales = c(motor = 70, cognitive = 30), subject_id = "P01",
               timestamp = "2026-07-26T09:00:00Z")
}

test_that("toFHIRObservation builds a well-formed R4 Observation", {
  obs <- toFHIRObservation(make_score(), derivedFrom = "DocumentReference/abc")
  expect_s3_class(obs, "fhir_observation")
  expect_equal(obs$resourceType, "Observation")
  expect_equal(obs$status, "final")
  expect_equal(obs$category[[1]]$coding[[1]]$code, "survey")
  expect_equal(obs$subject$reference, "Patient/P01")
  expect_equal(obs$effectiveDateTime, "2026-07-26T09:00:00Z")
  expect_equal(obs$valueQuantity$value, 100)
  expect_equal(length(obs$component), 2L)               # motor + cognitive
  expect_equal(obs$component[[1]]$valueQuantity$value, 70)
  expect_equal(obs$derivedFrom[[1]]$reference, "DocumentReference/abc")
  # an explicit subject / effective override the score fields
  o2 <- toFHIRObservation(make_score(), subject = "Patient/X",
                          effectiveDateTime = "2020-01-01")
  expect_equal(o2$subject$reference, "Patient/X")
  expect_equal(o2$effectiveDateTime, "2020-01-01")
  expect_error(toFHIRObservation(42), "ClinicalScore")
})

test_that("a mapped instrument gets its LOINC code, an unmapped one text-only", {
  gs <- methods::new("ClinicalScore", instrument_id = "gait_speed",
                     total = 1.25, subject_id = "P02")
  gobs <- toFHIRObservation(gs)
  expect_equal(gobs$code$coding[[1]]$code, "72106-8")
  expect_equal(gobs$code$coding[[1]]$system, "http://loinc.org")
  expect_equal(gobs$valueQuantity$unit, "m/s")
  # an instrument absent from the LOINC map falls back to a text-only code
  unk <- methods::new("ClinicalScore", instrument_id = "made_up_scale",
                      total = 5)
  uobs <- toFHIRObservation(unk)
  expect_null(uobs$code$coding)
  expect_equal(uobs$code$text, "made_up_scale")
})

test_that("the emitted Observation validates against the FHIR R4 schema", {
  skip_if_not_installed("jsonvalidate")
  skip_if_not_installed("jsonlite")
  expect_true(validateFHIRObservation(toFHIRObservation(make_score())))
  gs <- methods::new("ClinicalScore", instrument_id = "gait_speed",
                     total = 1.25, subject_id = "P02")
  expect_true(validateFHIRObservation(toFHIRObservation(gs)))
  # the schema actually rejects invalid resources
  bad <- toFHIRObservation(make_score()); class(bad) <- "list"
  bad$status <- NULL
  expect_false(validateFHIRObservation(bad))
  bad2 <- toFHIRObservation(make_score()); class(bad2) <- "list"
  bad2$status <- "not-a-status"
  expect_false(validateFHIRObservation(bad2))
})

test_that("a missing (NA) score uses dataAbsentReason, not a null value", {
  skip_if_not_installed("jsonvalidate")
  na_total <- methods::new("ClinicalScore", instrument_id = "berg",
                           total = NA_real_)
  obs <- toFHIRObservation(na_total)
  expect_null(obs$valueQuantity)                       # never value = null
  expect_equal(obs$dataAbsentReason$coding[[1]]$code, "unknown")
  expect_true(validateFHIRObservation(obs))
  # a missing subscale becomes a component with dataAbsentReason
  na_sub <- methods::new("ClinicalScore", instrument_id = "fim", total = 90,
                         subscales = c(motor = 60, cognitive = NA_real_))
  os <- toFHIRObservation(na_sub)
  expect_null(os$component[[2]]$valueQuantity)
  expect_false(is.null(os$component[[2]]$dataAbsentReason))
  expect_true(validateFHIRObservation(os))
})

test_that("a duplicated subscale name keeps each component value aligned", {
  sc <- methods::new("ClinicalScore", instrument_id = "fim", total = 90,
                     subscales = c(motor = 60, motor = 30), subject_id = "P01")
  obs <- toFHIRObservation(sc)
  # positional indexing: the two motor components carry 60 then 30, not 60, 60
  expect_equal(obs$component[[1]]$valueQuantity$value, 60)
  expect_equal(obs$component[[2]]$valueQuantity$value, 30)
})

test_that("subject_id is prefixed only when it is a bare id", {
  bare <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
                       subject_id = "999")
  expect_equal(toFHIRObservation(bare)$subject$reference, "Patient/999")
  # an id that is already a reference is used verbatim (no double prefix)
  ref <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
                      subject_id = "Patient/999")
  expect_equal(toFHIRObservation(ref)$subject$reference, "Patient/999")
  urn <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
                      subject_id = "urn:uuid:abc")
  expect_equal(toFHIRObservation(urn)$subject$reference, "urn:uuid:abc")
  # an explicit subject is always used as given
  expect_equal(toFHIRObservation(bare, subject = "Group/7")$subject$reference,
               "Group/7")
})

test_that("writeFHIRBundle round-trips subject / effective / value / components", {
  skip_if_not_installed("jsonlite")
  sc <- make_score()
  path <- tempfile(fileext = ".json")
  writeFHIRBundle(list(sc), path)
  expect_gt(file.size(path), 0)
  back <- jsonlite::read_json(path, simplifyVector = FALSE)
  expect_equal(back$resourceType, "Bundle")
  expect_equal(back$type, "collection")
  r <- back$entry[[1]]$resource
  expect_equal(r$subject$reference, "Patient/P01")
  expect_equal(r$effectiveDateTime, "2026-07-26T09:00:00Z")
  expect_equal(r$valueQuantity$value, 100)
  expect_equal(r$code$text, "Functional Independence Measure total score")
  expect_equal(length(r$component), 2L)
  expect_equal(r$component[[1]]$valueQuantity$value, 70)
})
