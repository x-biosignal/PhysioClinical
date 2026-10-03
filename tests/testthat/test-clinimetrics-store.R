test_that("every stored constant carries governance (DOI + provenance note)", {
  tbl <- listClinimetrics()
  expect_gt(nrow(tbl), 0L)
  expect_true(all(nzchar(tbl$reference_doi)) && !anyNA(tbl$reference_doi))
  expect_true(all(nzchar(tbl$provenance_note)) && !anyNA(tbl$provenance_note))
  expect_true(all(!is.na(tbl$population_n)))
  # the seed covers the instruments the WP requires
  expect_true(all(c("FMA-UE", "ARAT", "BBS", "10mWT", "6MWT", "TUG", "FIM") %in%
                    tbl$instrument))
})

test_that("seeded values match the cited literature fixtures", {
  # Page 2012 FMA-UE MCID: 4.25 (minimal) - 7.25 (moderate)
  expect_equal(
    getClinimetric("FMA-UE", "MCID_anchor", "chronic_stroke_minimal")$value,
    4.25)
  expect_equal(
    getClinimetric("FMA-UE", "MCID_anchor", "chronic_stroke_moderate")$value,
    7.25)
  # Perera 2006 gait speed: small meaningful 0.05, substantial 0.10 m/s
  # (Perera reports no MDC, so only the meaningful-change statistics are stored)
  expect_equal(getClinimetric("10mWT", "MCID_dist")$value, 0.05)
  expect_equal(getClinimetric("10mWT", "MCII")$value, 0.10)
  # the DOI is surfaced in the return value
  expect_equal(getClinimetric("10mWT", "MCII")$reference_doi,
               "10.1111/j.1532-5415.2006.00701.x")
})

test_that("getClinimetric is case-insensitive and surfaces provenance", {
  a <- getClinimetric("fma-ue", "mcid_anchor", "chronic_stroke_minimal")
  b <- getClinimetric("FMA-UE", "MCID_anchor", "chronic_stroke_minimal")
  expect_equal(a$value, b$value)
  expect_s3_class(a, "clinimetric")
  expect_true(all(c("value", "reference_doi", "population_n", "provenance_note")
                  %in% names(a)))
  expect_output(print(a), "doi:")
})

test_that("unknown population or instrument returns NA with a warning, not error", {
  expect_warning(x <- getClinimetric("FMA-UE", "MCID_anchor",
                                     population = "on_mars"), "population")
  expect_true(is.na(x))
  expect_warning(y <- getClinimetric("NOT_AN_INSTRUMENT", "MDC"), "instrument")
  expect_true(is.na(y))
  expect_warning(z <- getClinimetric("FMA-UE", "NOT_A_STAT"), "clinimetric")
  expect_true(is.na(z))
})

test_that("listClinimetrics filters by instrument", {
  all_tbl <- listClinimetrics()
  gait <- listClinimetrics("10mWT")
  expect_true(all(gait$instrument == "10mWT"))
  expect_lt(nrow(gait), nrow(all_tbl))
  expect_equal(nrow(listClinimetrics("nope")), 0L)
})
