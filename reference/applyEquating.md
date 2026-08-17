# Apply a score crosswalk to new values

Apply a score crosswalk to new values

## Usage

``` r
applyEquating(equating, values)
```

## Arguments

- equating:

  a `score_equating` from
  [`equateScores()`](https://x-biosignal.github.io/PhysioClinical/reference/equateScores.md).

- values:

  numeric source-scale values to convert.

## Value

numeric target-scale equivalents (linearly interpolated within the
crosswalk, clamped to its range).

## See also

[`equateScores()`](https://x-biosignal.github.io/PhysioClinical/reference/equateScores.md)

## Examples

``` r
set.seed(1)
ability <- rnorm(200)
barthel <- pmin(100, pmax(0, round((ability + 3) * 16 / 5) * 5))
fim <- pmin(126, pmax(18, round(18 + (ability + 3) * 18)))
applyEquating(equateScores(barthel, fim), c(40, 60, 80))
#> [1]  62.00  85.00 108.03
```
