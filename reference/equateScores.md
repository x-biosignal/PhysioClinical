# Equate one clinical score scale to another (build a crosswalk)

Constructs a conversion from a "source" scale to a "target" scale using
a linking sample measured on both. Equipercentile equating (the default)
maps a source score to the target score with the same percentile rank,
so it handles the non-linear, bounded relationship typical of ADL
scales; linear equating matches only the mean and SD.

## Usage

``` r
equateScores(
  from,
  to,
  method = c("equipercentile", "linear"),
  from_scores = sort(unique(from[is.finite(from)]))
)
```

## Arguments

- from:

  Numeric source-scale scores from the linking sample.

- to:

  Numeric target-scale scores from the linking sample (equipercentile
  uses the two marginal distributions; linear uses their means and SDs).

- method:

  `"equipercentile"` (default) or `"linear"`.

- from_scores:

  Source scores to tabulate (default: the sorted unique observed source
  scores).

## Value

an object of class `score_equating`: a list with `table` (data.frame
`from`, `to`), `method`, and the linking-sample size. Convert new values
with
[`applyEquating()`](https://x-biosignal.github.io/PhysioClinical/reference/applyEquating.md).

## References

Kolen MJ, Brennan RL (2004) Test Equating, Scaling, and Linking; Houlden
H et al. (2006) Clin Rehabil 20:153-159 (Barthel\<-\>FIM).

## See also

[`applyEquating()`](https://x-biosignal.github.io/PhysioClinical/reference/applyEquating.md)

## Examples

``` r
set.seed(1)
ability <- rnorm(200)
barthel <- pmin(100, pmax(0, round((ability + 3) * 16 / 5) * 5))
fim <- pmin(126, pmax(18, round(18 + (ability + 3) * 18)))
eq <- equateScores(barthel, fim)          # Barthel -> FIM crosswalk
head(eq$table)
#>   from     to
#> 1   15 36.985
#> 2   20 42.000
#> 3   25 46.000
#> 4   30 52.000
#> 5   35 58.000
#> 6   40 62.000
```
