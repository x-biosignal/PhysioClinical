# Score the Brief Pain Inventory (short form)

Scores the BPI severity (worst / least / average / current pain) and
interference (general activity, mood, walking, work, relations, sleep,
enjoyment of life) items, each 0-10. Severity and interference are
reported as their mean subscale scores (each 0-10, the conventional BPI
summaries); the total is the grand mean over all items.

## Usage

``` r
scoreBPI(items, ...)
```

## Arguments

- items:

  Named numeric responses (e.g. `worst_pain = 8`,
  `interference_sleep = 5`) or an unnamed vector in the instrument's
  item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing = "prorate"`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
whose `subscales` hold the severity and interference means.

## See also

[`scorePainNRS()`](https://x-biosignal.github.io/PhysioClinical/reference/scorePainNRS.md),
[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
scoreBPI(stats::setNames(c(8, 2, 5, 4, 5, 6, 5, 7, 3, 5, 6),
                         getInstrument("bpi")@items))
#> ClinicalScore [bpi]
#>   total = 5.090909
#>   subscales:
#>     severity         4.75
#>     interference     5.285714
#>   items used: 11, missing = error
```
