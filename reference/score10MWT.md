# Score a 10-metre walk test (10mWT)

Computes comfortable/fast gait speed and its ambulation category, with
an optional normative z-score. Accepts a gait speed directly, a walk
time, or a PhysioMoCap signal-derived result (`walk_test_report` from
[`PhysioMoCap::instrumented10mWT`](https://x-biosignal.r-universe.dev/PhysioMoCap/reference/instrumented10mWT.html)
or `gait_parameters` from
[`PhysioMoCap::calculateGaitParameters`](https://x-biosignal.r-universe.dev/PhysioMoCap/reference/calculateGaitParameters.html)).

## Usage

``` r
score10MWT(
  x = NULL,
  time_s = NULL,
  distance = 10,
  pace = c("comfortable", "fast"),
  ref = NULL,
  covariates = list()
)
```

## Arguments

- x:

  A gait speed (m/s), a `walk_test_report`, or a `gait_parameters`; or
  `NULL` to use `time_s`.

- time_s:

  Walk time in seconds (manual path; speed = `distance/time`).

- distance:

  Walk distance in metres (default 10).

- pace:

  `"comfortable"` (default) or `"fast"`.

- ref:

  Optional
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md)
  for the normative z-score.

- covariates:

  Covariates (e.g. `list(age, sex)`) for `ref`.

## Value

A `"performance_test_score"` with `gait_speed`, `ambulation` and (if
`ref`) `zscore`.

## References

Perry et al. (1995); Fritz & Lusardi (2009); Perera et al. (2006).

## See also

[`score6MWT()`](https://x-biosignal.github.io/PhysioClinical/reference/score6MWT.md),
[`scoreTUG()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreTUG.md)

## Examples

``` r
score10MWT(time_s = 8)         # 10 m / 8 s = 1.25 m/s -> community ambulator
#> <performance_test_score> 10mWT
#>   gait_speed         1.25
#>   pace               comfortable
#>   ambulation         community
```
