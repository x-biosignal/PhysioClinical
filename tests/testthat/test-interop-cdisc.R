make_cdisc_score <- function(instrument = "fim", ...) {
  args <- list(instrument_id = instrument, total = 90,
               subscales = c(motor = 60, cognitive = 30), subject_id = "001",
               timestamp = "2026-07-26T09:00:00Z")
  args[names(list(...))] <- list(...)
  do.call(methods::new, c("ClinicalScore", args))
}

test_that("toCDISC_QS produces a QS domain with the SDTMIG columns", {
  qs <- toCDISC_QS(make_cdisc_score(), studyid = "ABC")
  expect_s3_class(qs, "data.frame")
  expect_true(all(c("STUDYID", "DOMAIN", "USUBJID", "QSSEQ", "QSTESTCD",
                    "QSTEST", "QSCAT", "QSORRES", "QSSTRESC", "QSSTRESN",
                    "QSSTRESU", "VISITNUM", "QSDTC") %in% names(qs)))
  expect_true(all(qs$DOMAIN == "QS"))
})

test_that("a multi-item instrument exports the expected golden QS records", {
  qs <- toCDISC_QS(make_cdisc_score(), studyid = "ABC")
  expect_equal(nrow(qs), 3L)                              # total + 2 subscales
  expect_equal(qs$USUBJID, rep("ABC-001", 3))
  expect_equal(qs$QSSEQ, 1:3)
  expect_equal(qs$QSTESTCD, c("FIMTOT", "FIMMOT", "FIMCOG"))
  expect_equal(qs$QSTEST, c("FIM Total Score", "FIM Motor Subscale",
                            "FIM Cognitive Subscale"))
  expect_equal(qs$QSCAT, rep("FUNCTIONAL INDEPENDENCE MEASURE", 3))
  expect_equal(qs$QSSTRESN, c(90, 60, 30))
  expect_equal(qs$QSORRES, c("90", "60", "30"))
  expect_equal(qs$QSDTC, rep("2026-07-26T09:00:00Z", 3))
})

test_that("QSTESTCD and QSTEST honour the SDTM length limits", {
  # every packaged instrument
  insts <- c("gait_speed", "6mwt", "tug", "fma_ue", "fma_le", "berg", "arat",
             "nihss", "mrs", "fim", "fam")
  for (i in insts) {
    qs <- suppressWarnings(toCDISC_QS(
      methods::new("ClinicalScore", instrument_id = i, total = 1,
                   subject_id = "1")))
    expect_true(all(nchar(qs$QSTESTCD) <= 8), info = i)
    expect_true(all(nchar(qs$QSTEST) <= 40), info = i)
  }
  # a ct_map QSTESTCD over 8 chars is rejected
  bad <- data.frame(instrument = "berg", subscale = "total",
                    qstestcd = "TOOLONGCODE", qstest = "X", qscat = "Y",
                    stringsAsFactors = FALSE)
  expect_error(toCDISC_QS(make_cdisc_score("berg", subscales = numeric(0)),
                          ct_map = bad), "8-character")
})

test_that("required identifier/topic variables are never NA for well-formed input", {
  qs <- toCDISC_QS(make_cdisc_score())
  req <- c("STUDYID", "DOMAIN", "USUBJID", "QSSEQ", "QSTESTCD", "QSTEST")
  expect_false(any(is.na(qs[, req])))
})

test_that("units come from the LOINC map; unitless scores get NA QSSTRESU", {
  gs <- toCDISC_QS(methods::new("ClinicalScore", instrument_id = "gait_speed",
                                total = 1.25, subject_id = "2"))
  expect_equal(gs$QSSTRESU, "m/s")
  berg <- suppressWarnings(toCDISC_QS(
    methods::new("ClinicalScore", instrument_id = "berg", total = 45,
                 subject_id = "3")))
  expect_true(is.na(berg$QSSTRESU))          # {score} -> NA, not a literal unit
})

test_that("QSSEQ increments per subject across multiple scores", {
  s1 <- make_cdisc_score(subscales = numeric(0), subject_id = "001")  # 1 rec
  s2 <- make_cdisc_score("berg", total = 45, subscales = numeric(0),
                         subject_id = "001")                          # 1 rec
  s3 <- make_cdisc_score("tug", total = 12, subscales = numeric(0),
                         subject_id = "002")                          # 1 rec
  qs <- suppressWarnings(toCDISC_QS(list(s1, s2, s3)))
  expect_equal(qs$QSSEQ[qs$USUBJID == "STUDY-001"], c(1, 2))
  expect_equal(qs$QSSEQ[qs$USUBJID == "STUDY-002"], 1)
})

test_that("USUBJID uses studyid-subject, or a usubjid_map override", {
  qs <- toCDISC_QS(make_cdisc_score(subscales = numeric(0)), studyid = "S1")
  expect_equal(qs$USUBJID, "S1-001")
  qs2 <- toCDISC_QS(make_cdisc_score(subscales = numeric(0)),
                    usubjid_map = c("001" = "SITE1-PATIENT-7"))
  expect_equal(qs2$USUBJID, "SITE1-PATIENT-7")
})

test_that("an unmapped instrument gets a derived <=8 QSTESTCD with a warning", {
  expect_warning(qs <- toCDISC_QS(
    methods::new("ClinicalScore", instrument_id = "my_scale!x", total = 5,
                 subject_id = "9")), "CDISC CT")
  expect_equal(qs$QSTESTCD, "MYSCALEX")
  expect_true(nchar(qs$QSTESTCD) <= 8)
})

test_that("derived QSTESTCDs are collision-free and stay one-to-one with QSTEST", {
  # total and a subscale whose stems both fill 8 chars would collide on truncation
  sc <- methods::new("ClinicalScore", instrument_id = "berg_extended",
                     total = 50, subscales = c(balance = 30), subject_id = "1")
  qs <- suppressWarnings(toCDISC_QS(sc))
  expect_equal(length(unique(qs$QSTESTCD)), 2L)          # not both "BERGEXTE"
  expect_true(all(nchar(qs$QSTESTCD) <= 8))
  # two colliding subscales -> three distinct codes
  sc2 <- methods::new("ClinicalScore", instrument_id = "assessment", total = 1,
                      subscales = c(motorpart1 = 2, motorpart2 = 3),
                      subject_id = "1")
  qs2 <- suppressWarnings(toCDISC_QS(sc2))
  expect_equal(length(unique(qs2$QSTESTCD)), 3L)
  # a ct_map that maps two tests to one code is rejected (SDTM one-to-one)
  bad <- data.frame(instrument = c("berg", "tug"), subscale = c("total", "total"),
                    qstestcd = c("DUP", "DUP"), qstest = c("Berg", "Tug"),
                    qscat = c("A", "B"), stringsAsFactors = FALSE)
  expect_error(
    toCDISC_QS(list(methods::new("ClinicalScore", instrument_id = "berg", total = 1, subject_id = "1"),
                    methods::new("ClinicalScore", instrument_id = "tug", total = 2, subject_id = "1")),
               ct_map = bad), "one-to-one")
})

test_that("a derived QSTESTCD always starts with a letter", {
  for (i in c("9hole_peg", "10mwt", "6min")) {
    qs <- suppressWarnings(toCDISC_QS(
      methods::new("ClinicalScore", instrument_id = i, total = 1, subject_id = "1")))
    expect_match(qs$QSTESTCD, "^[A-Za-z]", info = i)
    expect_true(nchar(qs$QSTESTCD) <= 8, info = i)
  }
})

test_that("results are plain decimals, never scientific notation", {
  big <- toCDISC_QS(methods::new("ClinicalScore", instrument_id = "gait_speed",
                                 total = 100000, subject_id = "1"))
  expect_equal(big$QSORRES, "100000")
  expect_equal(big$QSSTRESC, "100000")
  small <- toCDISC_QS(methods::new("ClinicalScore", instrument_id = "gait_speed",
                                   total = 0.0001, subject_id = "1"))
  expect_equal(small$QSORRES, "0.0001")
})

test_that("a missing subject_id yields NA USUBJID with a warning", {
  expect_warning(qs <- toCDISC_QS(
    methods::new("ClinicalScore", instrument_id = "berg", total = 45)),
    "USUBJID")
  expect_true(is.na(qs$USUBJID))
})

test_that("a missing (NA) score still emits a record with NA results", {
  qs <- suppressWarnings(toCDISC_QS(
    methods::new("ClinicalScore", instrument_id = "berg", total = NA_real_,
                 subject_id = "1")))
  expect_equal(nrow(qs), 1L)
  expect_true(is.na(qs$QSSTRESN))
  expect_true(is.na(qs$QSORRES))
})

test_that("toADaM_ADQS builds a BDS from scores or a QS data frame", {
  ad <- toADaM_ADQS(make_cdisc_score(), studyid = "ABC")
  expect_true(all(c("STUDYID", "USUBJID", "PARAMCD", "PARAM", "PARCAT1",
                    "AVAL", "AVALC", "AVISITN", "ADT") %in% names(ad)))
  expect_equal(ad$PARAMCD, c("FIMTOT", "FIMMOT", "FIMCOG"))
  expect_equal(ad$AVAL, c(90, 60, 30))
  expect_equal(ad$ADT, rep("2026-07-26", 3))             # date part of QSDTC
  # from an existing QS data frame -> identical BDS
  qs <- toCDISC_QS(make_cdisc_score(), studyid = "ABC")
  expect_equal(toADaM_ADQS(qs), ad)
})

test_that("toCDISC_QS and toADaM_ADQS validate their input", {
  expect_error(toCDISC_QS(42), "ClinicalScore")
  expect_error(toCDISC_QS(list()), "non-empty")
  expect_error(toADaM_ADQS(data.frame(x = 1)), "QS-domain")
})
