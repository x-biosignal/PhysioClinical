make_omop_score <- function(instrument = "fim", ...) {
  args <- list(instrument_id = instrument, total = 90,
               subscales = c(motor = 60, cognitive = 30), subject_id = "1001",
               timestamp = "2026-07-26T09:00:00Z")
  args[names(list(...))] <- list(...)
  do.call(methods::new, c("ClinicalScore", args))
}

test_that("toOMOP produces MEASUREMENT/OBSERVATION tables with the CDM columns", {
  res <- suppressWarnings(toOMOP(make_omop_score()))
  expect_named(res, c("MEASUREMENT", "OBSERVATION"))
  expect_s3_class(res$MEASUREMENT, "data.frame")
  expect_true(all(c("measurement_id", "person_id", "measurement_concept_id",
                    "measurement_date", "measurement_type_concept_id",
                    "value_as_number", "unit_concept_id") %in%
                    names(res$MEASUREMENT)))
  expect_true(all(c("observation_id", "person_id", "observation_concept_id",
                    "observation_date", "observation_type_concept_id",
                    "value_as_number") %in% names(res$OBSERVATION)))
})

test_that("required OMOP fields are non-null and rows are one per total+subscale", {
  res <- suppressWarnings(toOMOP(make_omop_score()))  # fim -> Observation domain
  expect_equal(nrow(res$OBSERVATION), 3L)             # total + motor + cognitive
  expect_equal(nrow(res$MEASUREMENT), 0L)
  req <- c("observation_id", "person_id", "observation_concept_id",
           "observation_date", "observation_type_concept_id")
  expect_false(any(is.na(res$OBSERVATION[, req])))
  expect_equal(res$OBSERVATION$observation_id, 1:3)   # sequential ids
  # subscale values stay aligned to their source_value
  expect_equal(res$OBSERVATION$value_as_number,
               c(90, 60, 30))
  expect_equal(res$OBSERVATION$observation_source_value,
               c("fim", "fim:motor", "fim:cognitive"))
})

test_that("gait_speed routes to MEASUREMENT and reuses the LOINC UCUM unit", {
  gs <- methods::new("ClinicalScore", instrument_id = "gait_speed",
                     total = 1.25, subject_id = "42",
                     timestamp = "2026-07-26T10:00:00Z")
  res <- suppressWarnings(toOMOP(gs))
  expect_equal(nrow(res$MEASUREMENT), 1L)
  expect_equal(nrow(res$OBSERVATION), 0L)
  expect_equal(res$MEASUREMENT$unit_source_value, "m/s")
  expect_equal(res$MEASUREMENT$value_as_number, 1.25)
  expect_equal(res$MEASUREMENT$value_source_value, "1.25")
})

test_that("an unmapped instrument gets concept_id 0 with a warning; a map gives a real id", {
  # the shipped map has no Athena concept_id -> 0 + warning
  expect_warning(res <- toOMOP(make_omop_score(instrument = "berg", subscales = numeric(0))),
                 "concept_id")
  expect_equal(res$OBSERVATION$observation_concept_id, 0L)
  # a site concept_map supplies a non-zero id -> mapped, no warning
  cmap <- data.frame(instrument = "berg", subscale = "total",
                     domain_id = "Observation", measurement_concept_id = "9999999",
                     unit_concept_id = "0", stringsAsFactors = FALSE)
  expect_silent(res2 <- toOMOP(make_omop_score(instrument = "berg", subscales = numeric(0)),
                               concept_map = cmap))
  expect_equal(res2$OBSERVATION$observation_concept_id, 9999999L)
})

test_that("person_id resolves from an integer id, a person_map, else NA + warning", {
  # a concept_map so only the person_id warning fires (isolating this behaviour)
  cmap <- data.frame(instrument = "fim", subscale = "total",
                     domain_id = "Observation", measurement_concept_id = "9999999",
                     unit_concept_id = "0", stringsAsFactors = FALSE)
  # integer-like subject_id used directly
  res <- toOMOP(make_omop_score(subject_id = "1001", subscales = numeric(0)),
                concept_map = cmap)
  expect_equal(res$OBSERVATION$person_id, 1001L)
  # a non-integer id is unresolved -> NA + warning
  expect_warning(res2 <- toOMOP(make_omop_score(subject_id = "ABC-1", subscales = numeric(0)),
                                concept_map = cmap),
                 "person_id")
  expect_true(is.na(res2$OBSERVATION$person_id))
  # a person_map resolves it
  res3 <- toOMOP(make_omop_score(subject_id = "ABC-1", subscales = numeric(0)),
                 concept_map = cmap, person_map = c("ABC-1" = 555L))
  expect_equal(res3$OBSERVATION$person_id, 555L)
  # only plain positive-integer ids are used directly - no "1e3"/"1.0"/" 5 " surprises
  for (bad in c("1e3", "1.0", " 5 ", "0")) {
    r <- suppressWarnings(toOMOP(make_omop_score(subject_id = bad, subscales = numeric(0)),
                                 concept_map = cmap))
    expect_true(is.na(r$OBSERVATION$person_id), info = bad)
  }
})

test_that("a missing (NA) score still emits a row with an NA value", {
  na_sc <- make_omop_score(instrument = "berg", total = NA_real_,
                           subscales = numeric(0))
  res <- suppressWarnings(toOMOP(na_sc))
  expect_equal(nrow(res$OBSERVATION), 1L)
  expect_true(is.na(res$OBSERVATION$value_as_number))
  expect_true(is.na(res$OBSERVATION$value_as_string))
})

test_that("a duplicated subscale name keeps each value aligned to its row", {
  sc <- methods::new("ClinicalScore", instrument_id = "fim", total = 90,
                     subscales = c(motor = 60, motor = 30), subject_id = "1001",
                     timestamp = "2026-07-26T09:00:00Z")
  res <- suppressWarnings(toOMOP(sc))
  # positional, not by-name: the two motor rows keep 60 then 30 (not 60, 60)
  expect_equal(res$OBSERVATION$value_as_number, c(90, 60, 30))
})

test_that("a malformed concept_id cell falls back to 0 with a warning", {
  frac <- data.frame(instrument = "berg", subscale = "total",
                     domain_id = "Observation", measurement_concept_id = "12.9",
                     unit_concept_id = "0", stringsAsFactors = FALSE)
  # two warnings fire: the malformed cell, then the resulting unmapped->0
  expect_warning(
    expect_warning(
      r1 <- toOMOP(make_omop_score(instrument = "berg", subscales = numeric(0)),
                   concept_map = frac),
      "not a valid non-negative integer"),
    "no OMOP concept_id")
  expect_equal(r1$OBSERVATION$observation_concept_id, 0L)   # not silently 12
  neg <- frac; neg$measurement_concept_id <- "-5"
  expect_warning(
    expect_warning(
      r2 <- toOMOP(make_omop_score(instrument = "berg", subscales = numeric(0)),
                   concept_map = neg),
      "not a valid non-negative integer"),
    "no OMOP concept_id")
  expect_equal(r2$OBSERVATION$observation_concept_id, 0L)   # not invalid -5
})

test_that("type_concept_id is applied to both domains", {
  res <- suppressWarnings(toOMOP(make_omop_score(), type_concept_id = 32817L))
  expect_true(all(res$OBSERVATION$observation_type_concept_id == 32817L))
})

test_that("toOMOP validates its input", {
  expect_error(toOMOP(42), "ClinicalScore")
  expect_error(toOMOP(list()), "non-empty")
  expect_error(toOMOP(list(make_omop_score(), 1)), "ClinicalScore")
})

test_that("writeOMOPTables writes one CSV per non-empty table and round-trips", {
  scores <- list(
    make_omop_score(),                                             # 3 obs rows
    methods::new("ClinicalScore", instrument_id = "gait_speed",    # 1 meas row
                 total = 1.1, subject_id = "2",
                 timestamp = "2026-07-26T09:00:00Z"))
  d <- tempfile()
  files <- suppressWarnings(writeOMOPTables(scores, d))
  expect_setequal(basename(files), c("measurement.csv", "observation.csv"))
  obs <- utils::read.csv(file.path(d, "observation.csv"), stringsAsFactors = FALSE)
  expect_equal(nrow(obs), 3L)
  expect_equal(obs$person_id[1], 1001L)
  expect_equal(obs$value_as_number, c(90, 60, 30))
  meas <- utils::read.csv(file.path(d, "measurement.csv"), stringsAsFactors = FALSE)
  expect_equal(meas$unit_source_value, "m/s")
  expect_equal(meas$value_as_number, 1.1)
})

test_that("writeOMOPTables also accepts a toOMOP() result and skips empty tables", {
  tabs <- suppressWarnings(toOMOP(make_omop_score()))  # only OBSERVATION populated
  d <- tempfile()
  files <- writeOMOPTables(tabs, d)
  expect_equal(basename(files), "observation.csv")     # empty MEASUREMENT skipped
})
