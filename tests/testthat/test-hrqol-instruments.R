# Bundled health-related quality-of-life instrument: EQ-5D-5L level-sum score.

test_that("EQ-5D-5L sums five dimension levels to a 5-25 level-sum score", {
  perfect <- scoreEQ5D5L(c(mobility = 1, self_care = 1, usual_activities = 1,
                           pain_discomfort = 1, anxiety_depression = 1))
  expect_equal(perfect@total, 5)
  worst <- scoreEQ5D5L(c(mobility = 5, self_care = 5, usual_activities = 5,
                         pain_discomfort = 5, anxiety_depression = 5))
  expect_equal(worst@total, 25)

  sc <- scoreEQ5D5L(c(mobility = 2, self_care = 1, usual_activities = 2,
                      pain_discomfort = 3, anxiety_depression = 2))
  expect_equal(sc@total, 10)
  expect_equal(getInstrument("eq5d5l")@direction, "higher_worse")

  # levels are 1-5 integers; there is no bundled utility index / value set
  expect_error(scoreEQ5D5L(c(mobility = 0, self_care = 1, usual_activities = 1,
                             pain_discomfort = 1, anxiety_depression = 1)),
               "range")
})

test_that("all Tier-2 clinical instruments are registered and documented", {
  ids <- listInstruments()
  new_ids <- c("mmse", "moca", "pain_nrs", "bpi", "mrc_sum", "fss", "mfis",
               "eq5d5l")
  expect_true(all(new_ids %in% ids))
  for (id in new_ids) {
    inst <- getInstrument(id)
    expect_false(is.na(inst@source_ref))                 # provenance cited
    expect_true(inst@direction %in% c("higher_better", "higher_worse"))
  }
})
