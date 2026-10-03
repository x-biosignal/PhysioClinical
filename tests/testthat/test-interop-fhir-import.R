# fromFHIR: import a FHIR Observation back into a ClinicalScore.

test_that("fromFHIR round-trips an unmapped instrument (text-only code)", {
  sc <- methods::new("ClinicalScore", instrument_id = "custom_scale", total = 42,
    subscales = c(part_a = 20, part_b = 22), stratum = NA_character_,
    items_used = character(0), missing_handling = "error",
    timestamp = "2026-07-26T09:00:00Z", subject_id = "P07")
  back <- fromFHIR(toFHIRObservation(sc))
  expect_s4_class(back, "ClinicalScore")
  expect_equal(back@instrument_id, "custom_scale")
  expect_equal(back@total, 42)
  expect_equal(back@subject_id, "P07")               # Patient/ prefix stripped
  expect_equal(back@timestamp, "2026-07-26T09:00:00Z")
  expect_equal(back@subscales[["part_a"]], 20)
  expect_equal(back@subscales[["part_b"]], 22)
  # documented lossy slots
  expect_length(back@items_used, 0)
  expect_true(is.na(back@missing_handling))
})

test_that("fromFHIR recovers a LOINC-coded instrument", {
  sc <- methods::new("ClinicalScore", instrument_id = "gait_speed", total = 1.2,
    subscales = stats::setNames(numeric(0), character(0)), stratum = NA_character_,
    items_used = character(0), missing_handling = "error",
    timestamp = NA_character_, subject_id = "P42")
  obs <- toFHIRObservation(sc)
  expect_identical(obs$code$coding[[1]]$system, "http://loinc.org")  # LOINC path
  back <- fromFHIR(obs)
  expect_equal(back@instrument_id, "gait_speed")
  expect_equal(back@total, 1.2)
  expect_equal(back@subject_id, "P42")
})

test_that("fromFHIR re-derives the stratum for a registered instrument", {
  sc <- scoreInstrument("barthel",
    stats::setNames(rep(0, 10), getInstrument("barthel")@items))   # total 0
  back <- fromFHIR(toFHIRObservation(sc))
  expect_equal(back@instrument_id, "barthel")
  expect_equal(back@total, 0)
  expect_equal(back@stratum, "total_dependence")     # re-derived via assignStratum
})

test_that("fromFHIR maps dataAbsentReason to NA and parses a JSON string", {
  skip_if_not_installed("jsonlite")
  sc <- methods::new("ClinicalScore", instrument_id = "custom_scale",
    total = NA_real_, subscales = stats::setNames(numeric(0), character(0)),
    stratum = NA_character_, items_used = character(0), missing_handling = "na",
    timestamp = NA_character_, subject_id = NA_character_)
  obs <- toFHIRObservation(sc)
  expect_null(obs$valueQuantity)                      # dataAbsentReason used
  json <- jsonlite::toJSON(unclass(obs), auto_unbox = TRUE, null = "null")
  back <- fromFHIR(as.character(json))
  expect_true(is.na(back@total))
  expect_equal(back@instrument_id, "custom_scale")
})

test_that("fromFHIR rejects a non-Observation", {
  expect_error(fromFHIR(list(resourceType = "Patient")),
               "must be a FHIR Observation")
})
