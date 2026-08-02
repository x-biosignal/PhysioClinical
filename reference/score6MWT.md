# Score a 6-minute walk test (6MWT)

Reports the walked distance with, when the demographics are supplied,
the Enright & Sherrill (1998) predicted distance, percent-predicted and
the lower limit of normal (LLN), plus an optional normative z-score.

## Usage

``` r
score6MWT(
  distance_m,
  age = NULL,
  sex = NULL,
  height_cm = NULL,
  weight_kg = NULL,
  ref = NULL,
  covariates = list()
)
```

## Arguments

- distance_m:

  Distance walked in 6 minutes (metres).

- age, sex, height_cm, weight_kg:

  Demographics for the Enright reference equation (all four required for
  the predicted value).

- ref, covariates:

  Optional normative reference / covariates for a z-score.

## Value

A `"performance_test_score"` with `distance`, and (when demographics are
given) `predicted`, `percent_predicted`, `lln` and `below_lln`.

## References

Enright PL, Sherrill DL (1998). *Am J Respir Crit Care Med* 158(5),
1384-1387.
[doi:10.1164/ajrccm.158.5.9710086](https://doi.org/10.1164/ajrccm.158.5.9710086)

## See also

[`score10MWT()`](https://x-biosignal.github.io/PhysioClinical/reference/score10MWT.md),
[`scoreTUG()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreTUG.md)

## Examples

``` r
score6MWT(450, age = 60, sex = "male", height_cm = 175, weight_kg = 75)
#> <performance_test_score> 6MWT
#>   distance           450
#>   predicted          582.55
#>   lln                429.55
#>   percent_predicted  77.24659
#>   below_lln          FALSE
```
