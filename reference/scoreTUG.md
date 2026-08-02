# Score a Timed Up and Go test (TUG)

Classifies TUG time against the standard fall-risk cut-offs (`< 10 s`
normal; `>= 13.5 s` elevated community-dwelling fall risk, Shumway-Cook
2000; `>= 30 s` likely dependent, Podsiadlo & Richardson 1991), with an
optional normative z-score.

## Usage

``` r
scoreTUG(x, ref = NULL, covariates = list())
```

## Arguments

- x:

  A TUG time in seconds, or a PhysioMoCap `itug_report` (its
  `total_duration` is used).

- ref, covariates:

  Optional normative reference / covariates for a z-score.

## Value

A `"performance_test_score"` with `time`, `category` and `fall_risk`
(logical, `>= 13.5 s`).

## References

Podsiadlo & Richardson (1991); Shumway-Cook et al. (2000).

## See also

[`score10MWT()`](https://x-biosignal.github.io/PhysioClinical/reference/score10MWT.md),
[`score6MWT()`](https://x-biosignal.github.io/PhysioClinical/reference/score6MWT.md)

## Examples

``` r
scoreTUG(15)   # >= 13.5 s -> elevated fall risk
#> <performance_test_score> TUG
#>   time               15
#>   category           elevated_fall_risk
#>   fall_risk          TRUE
```
