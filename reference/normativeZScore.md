# Normative z-score / percentile for an observation

Standardizes an observed `value` against a governed normative reference,
selecting the covariate-matched stratum and applying either a Gaussian
\\(value - \mu)/\sigma\\ (stratified mean/sd model) or the Cole (1990)
LMS transform (LMS model). An unmatched or unsupported stratum raises an
error rather than returning a silent `NA`.

## Usage

``` r
normativeZScore(value, ref, covariates = list(), deviation_z = 2)
```

## Arguments

- value:

  Numeric observed value.

- ref:

  A
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md).

- covariates:

  Named list of covariates (e.g. `list(age = 68, sex = "M")`) covering
  the reference's `strata_vars`.

- deviation_z:

  Absolute z above which `deviation_flag` is set (default 2).

## Value

A list with `z`, `percentile` (0-100), `deviation_flag` and
`extrapolation`.

## References

Cole TJ (1990). The LMS method for constructing normalized growth
standards. *Eur J Clin Nutr* 44(1), 45-60.

## See also

[`matchStratum()`](https://x-biosignal.github.io/PhysioClinical/reference/matchStratum.md),
[`normativeDeviation()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeDeviation.md)

## Examples

``` r
ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
  provenance = list(source = "x"), consent = list(status = "public"),
  license = list(spdx = "CC0-1.0"),
  governance = list(custodian = "lab", access_level = "open"),
  strata_vars = "sex",
  model = list(type = "strata",
               table = data.frame(sex = "M", mean = 1.3, sd = 0.2)))
normativeZScore(1.0, ref, list(sex = "M"))
#> $z
#> [1] -1.5
#> 
#> $percentile
#> [1] 6.68072
#> 
#> $deviation_flag
#> [1] FALSE
#> 
#> $extrapolation
#> [1] FALSE
#> 
```
