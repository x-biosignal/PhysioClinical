# Convert a PROMIS summed score to a T-score via a lookup table

The other official PROMIS scoring path for a full short form: map the
summed raw score to a T-score with the instrument's published
summed-score-to-T-score table. The table is not bundled - obtain it from
the HealthMeasures scoring manual for the specific short form.

## Usage

``` r
promisRawToT(raw, conversion_table)
```

## Arguments

- raw:

  Summed raw score.

- conversion_table:

  A data.frame with a `raw` column, a `tscore` column and optionally an
  `se` column (the published conversion table).

## Value

A list with `tscore` and `se` (`NA` if the table has no `se` column);
`NA` with a warning if `raw` is not in the table.

## See also

[`scorePROMIS()`](https://x-biosignal.github.io/PhysioClinical/reference/scorePROMIS.md)

## Examples

``` r
tab <- data.frame(raw = 4:8, tscore = c(21.5, 30.1, 35.7, 40.2, 44.0))
promisRawToT(6, tab)
#> $tscore
#> [1] 35.7
#> 
#> $se
#> [1] NA
#> 
```
