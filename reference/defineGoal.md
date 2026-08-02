# Define a Goal Attainment Scaling goal

Describes one GAS goal: its attainment levels (typically `-2:2` with 0 =
expected outcome), a weight, and an optional ICF linkage. When both
`importance` and `difficulty` are given the (Turner-Stokes) weight is
their product; otherwise `weight` is used (default 1, i.e. unweighted
GAS).

## Usage

``` r
defineGoal(
  description,
  levels = -2:2,
  weight = 1,
  importance = NULL,
  difficulty = NULL,
  icf_tag = NULL
)
```

## Arguments

- description:

  Free-text goal description.

- levels:

  Ordered numeric attainment levels (must include 0, the expected
  outcome); default `-2:2`.

- weight:

  Goal weight when `importance`/`difficulty` are not supplied (default
  1, positive).

- importance, difficulty:

  Optional 0+ ratings; if both given the weight is
  `importance * difficulty`.

- icf_tag:

  Optional ICF code (e.g. `"d450"`) linking the goal to the
  International Classification of Functioning.

## Value

A `"gas_goal"` object.

## References

Kiresuk & Sherman (1968); Turner-Stokes (2009).

## See also

[`scoreGAS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreGAS.md)

## Examples

``` r
defineGoal("Walk 100 m unaided", importance = 3, difficulty = 2,
           icf_tag = "d450")
#> $description
#> [1] "Walk 100 m unaided"
#> 
#> $levels
#> [1] -2 -1  0  1  2
#> 
#> $weight
#> [1] 6
#> 
#> $importance
#> [1] 3
#> 
#> $difficulty
#> [1] 2
#> 
#> $icf_tag
#> [1] "d450"
#> 
#> attr(,"class")
#> [1] "gas_goal"
```
