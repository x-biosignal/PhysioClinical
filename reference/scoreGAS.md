# Score Goal Attainment Scaling (GAS T-score)

Computes the standardized GAS T-score across a set of goals given their
attained levels: \$\$T = 50 + \frac{10 \sum_i w_i
x_i}{\sqrt{(1-\rho)\sum_i w_i^2 + \rho (\sum_i w_i)^2}}\$\$ where
\\x_i\\ is the attained level, \\w_i\\ the weight and \\\rho\\ the
assumed inter-goal correlation. All goals at their expected level (\\x_i
= 0\\) give \\T = 50\\.

## Usage

``` r
scoreGAS(goals, attained_levels, rho = 0.3)
```

## Arguments

- goals:

  A
  [`defineGoal`](https://x-biosignal.github.io/PhysioClinical/reference/defineGoal.md)
  object or a list of them.

- attained_levels:

  Numeric attained level for each goal (each within that goal's
  `levels`).

- rho:

  Assumed inter-goal correlation in `[0, 1)`; default 0.3.

## Value

A `"gas_result"` with the T-score, per-goal weights/levels and `rho`.

## References

Kiresuk & Sherman (1968); Turner-Stokes (2009).

## See also

[`defineGoal()`](https://x-biosignal.github.io/PhysioClinical/reference/defineGoal.md),
[`gasSummary()`](https://x-biosignal.github.io/PhysioClinical/reference/gasSummary.md)

## Examples

``` r
g1 <- defineGoal("Transfers", importance = 3, difficulty = 2)
g2 <- defineGoal("Stairs", importance = 2, difficulty = 3)
scoreGAS(list(g1, g2), attained_levels = c(1, 0))
#> <gas_result> T = 56.20  (2 goal(s), weighted, rho = 0.3)
#>  description weight attained contribution
#>    Transfers      6        1            6
#>       Stairs      6        0            0
```
