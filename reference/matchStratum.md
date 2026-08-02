# Match the normative stratum for a set of covariates

Selects the row of a governed normative reference's model table that
matches the supplied covariates: categorical stratification variables
(e.g. sex) are matched exactly, numeric ones (e.g. age, speed) by
nearest value. A covariate falling outside the tabulated range is
flagged as an extrapolation.

## Usage

``` r
matchStratum(ref, covariates)
```

## Arguments

- ref:

  A
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md).

- covariates:

  Named list of covariate values covering the reference's `strata_vars`.

## Value

A one-row `data.frame` (the matched stratum) with an `"extrapolation"`
attribute (logical).

## See also

[`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md),
[`normativeDeviation()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeDeviation.md)

## Examples

``` r
ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
  provenance = list(source = "x"), consent = list(status = "public"),
  license = list(spdx = "CC0-1.0"),
  governance = list(custodian = "lab", access_level = "open"),
  strata_vars = c("age", "sex"),
  model = list(type = "strata", table = data.frame(
    age = c(60, 70), sex = "M", mean = c(1.4, 1.3), sd = 0.2)))
matchStratum(ref, list(age = 68, sex = "M"))
#>   age sex mean  sd
#> 2  70   M  1.3 0.2
```
