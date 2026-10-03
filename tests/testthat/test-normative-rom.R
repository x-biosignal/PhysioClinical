# Packaged joint range-of-motion reference values + comparison.

test_that("romReference returns the packaged table and filters", {
  all <- romReference()
  expect_s3_class(all, "data.frame")
  expect_setequal(names(all),
                  c("joint", "motion", "plane", "reference_deg", "source"))
  expect_equal(nrow(all), 25L)
  expect_true(all(is.finite(all$reference_deg)) && all(all$reference_deg >= 0))
  expect_true(all(nzchar(all$source)))

  expect_equal(nrow(romReference("knee")), 2L)             # flexion, extension
  expect_equal(nrow(romReference(motion = "flexion")), 5L) # sh/el/wr/hip/knee
  hf <- romReference("hip", "flexion")
  expect_equal(nrow(hf), 1L)
  expect_equal(hf$reference_deg, 120)
  expect_equal(romReference("KNEE", "FLEXION")$reference_deg, 135)  # case-insens
})

test_that("romNormalcy compares to reference and contralateral", {
  r <- romNormalcy(100, "knee", "flexion")
  expect_s3_class(r, "rom_normalcy")
  expect_equal(r$reference_deg, 135)
  expect_equal(r$percent_of_normal, 100 * 100 / 135)
  expect_equal(r$deficit_vs_reference, 35)
  expect_true(r$limited)

  full <- romNormalcy(120, "hip", "flexion")
  expect_equal(full$percent_of_normal, 100)
  expect_equal(full$deficit_vs_reference, 0)
  expect_false(full$limited)

  side <- romNormalcy(100, "knee", "flexion", contralateral = 130)
  expect_equal(side$deficit_vs_contralateral, 30)
  expect_equal(side$percent_of_contralateral, 100 * 100 / 130)

  # an extension-to-neutral motion has a 0 deg reference => percent is NA
  ext <- romNormalcy(0, "knee", "extension")
  expect_true(is.na(ext$percent_of_normal))
  expect_equal(ext$deficit_vs_reference, 0)
})

test_that("romNormalcy errors informatively on unknown joint/motion", {
  expect_error(romNormalcy(90, "knee", "bend"), "no ROM reference")
  expect_error(romNormalcy(90, "neck", "flexion"), "unknown joint")
  expect_error(romNormalcy(c(90, 100), "knee", "flexion"), "single finite")
})
