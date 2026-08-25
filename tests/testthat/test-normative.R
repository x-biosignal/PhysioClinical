make_ref <- function(version = "1.0.0",
                     provenance = list(source = "Bohannon 1997", doi = "10.x"),
                     consent = list(status = "public_aggregate"),
                     license = list(spdx = "CC-BY-4.0", redistribution_ok = TRUE),
                     governance = list(custodian = "Matsui Lab",
                                       access_level = "open")) {
  GovernedNormativeReference(
    id = "gait_speed_adult", modality = "gait", metric = "gait_speed",
    version = version, provenance = provenance, consent = consent,
    license = license, governance = governance,
    strata_vars = c("age", "sex"),
    model = list(type = "strata",
                 table = data.frame(age = 70, sex = "M", mean = 1.3, sd = 0.2)),
    n = 230)
}

test_that("validity requires provenance, consent and license", {
  expect_s4_class(make_ref(), "GovernedNormativeReference")
  expect_error(make_ref(consent = list()), "consent")
  expect_error(make_ref(license = list()), "license")
  expect_error(make_ref(provenance = list()), "provenance")
  expect_error(make_ref(version = "1.0"), "semver")
  expect_error(
    GovernedNormativeReference("", "gait", "gs", provenance = list(source = "x"),
                       consent = list(status = "p"),
                       license = list(spdx = "CC0-1.0")),
    "'id'")
})

test_that("blank / NA governance values cannot slip past the gate", {
  expect_error(make_ref(consent = list(status = "   ")), "consent")
  expect_error(make_ref(consent = list(status = NA)), "consent")
  expect_error(make_ref(license = list(spdx = character(0))), "license")
  expect_error(make_ref(provenance = list(source = "  ")), "provenance")
})

test_that("a path-traversal / unsafe id is rejected", {
  expect_error(
    GovernedNormativeReference("../evil", "gait", "gs", provenance = list(source = "x"),
                       consent = list(status = "p"),
                       license = list(spdx = "CC0-1.0")), "slug")
  expect_error(
    GovernedNormativeReference("a/b", "gait", "gs", provenance = list(source = "x"),
                       consent = list(status = "p"),
                       license = list(spdx = "CC0-1.0")), "slug")
  expect_s4_class(
    GovernedNormativeReference("gait_speed.adult-70", "gait", "gs",
                       provenance = list(source = "x"),
                       consent = list(status = "p"),
                       license = list(spdx = "CC0-1.0")),
    "GovernedNormativeReference")
})

test_that("registry round-trips register -> get across two semver versions", {
  root <- tempfile("normreg")
  registerNormative(make_ref("1.0.0"), root = root)
  registerNormative(make_ref("1.2.0"), root = root)

  expect_equal(getNormative("gait_speed_adult", root = root)@version, "1.2.0")
  expect_equal(
    getNormative("gait_speed_adult", version = "1.0.0", root = root)@version,
    "1.0.0")
  # a version 1.10.0 must sort above 1.2.0 (numeric, not lexical, semver)
  registerNormative(make_ref("1.10.0"), root = root)
  expect_equal(getNormative("gait_speed_adult", root = root)@version, "1.10.0")

  tbl <- listNormative(root = root)
  expect_equal(nrow(tbl), 3L)
  expect_setequal(tbl$version, c("1.0.0", "1.2.0", "1.10.0"))
  expect_true(all(tbl$id == "gait_speed_adult"))
})

test_that("registry guards double-registration and missing artifacts", {
  root <- tempfile("normreg")
  registerNormative(make_ref("1.0.0"), root = root)
  expect_error(registerNormative(make_ref("1.0.0"), root = root), "already")
  expect_silent(registerNormative(make_ref("1.0.0"), root = root,
                                  overwrite = TRUE))
  expect_error(getNormative("does_not_exist", root = root), "no registered")
  expect_error(getNormative("gait_speed_adult", version = "9.9.9", root = root),
               "not found")
  expect_equal(nrow(listNormative(root = tempfile("empty"))), 0L)
})

test_that("getNormative rejects traversal ids/versions and re-validates on read", {
  root <- tempfile("normreg")
  registerNormative(make_ref("1.0.0"), root = root)
  # crafted id/version must not climb out of the registry root
  expect_error(getNormative("../../etc", root = root), "slug")
  expect_error(
    getNormative("gait_speed_adult", version = "../../x", root = root), "semver")
  # an ungoverned .rds written out of band is rejected on read (validObject)
  bad <- make_ref("2.0.0")
  bad@consent <- list()   # S4 slot assignment does not re-run validity
  saveRDS(bad, file.path(root, "gait_speed_adult", "2.0.0.rds"))
  expect_error(
    getNormative("gait_speed_adult", version = "2.0.0", root = root), "consent")
})

test_that("a numeric NA-sentinel (NaN) cannot pose as a governance value", {
  expect_error(make_ref(consent = list(status = NaN)), "consent")
  expect_error(make_ref(license = list(spdx = NaN)), "license")
})

test_that("validateNormativeManifest rejects a missing governance field", {
  ok <- list(version = "1.0.0", provenance = list(source = "x"),
             consent = list(status = "public"), license = list(spdx = "CC0-1.0"),
             governance = list(custodian = "lab", access_level = "open"))
  expect_true(validateNormativeManifest(ok))
  expect_error(validateNormativeManifest(within(ok, governance <- list(access_level = "open"))),
               "custodian")
  expect_error(validateNormativeManifest(within(ok, consent <- list())),
               "consent.status")
  expect_error(validateNormativeManifest(within(ok, version <- "1.0")),
               "version")
  # a GovernedNormativeReference validates as its own manifest
  expect_true(validateNormativeManifest(make_ref()))
})

test_that("registered artifacts get a governance manifest.json", {
  skip_if_not_installed("jsonlite")
  root <- tempfile("normreg")
  registerNormative(make_ref("2.0.0"), root = root)
  mf <- file.path(root, "gait_speed_adult", "2.0.0.manifest.json")
  expect_true(file.exists(mf))
  expect_true(validateNormativeManifest(mf))
  parsed <- jsonlite::read_json(mf, simplifyVector = TRUE)
  expect_equal(parsed$license$spdx, "CC-BY-4.0")
})

test_that("show surfaces the governance metadata", {
  out <- capture.output(make_ref())
  expect_true(any(grepl("GovernedNormativeReference", out)))
  expect_true(any(grepl("Bohannon 1997", out)))
  expect_true(any(grepl("CC-BY-4.0", out)))
  expect_true(any(grepl("access: open", out)))
})
