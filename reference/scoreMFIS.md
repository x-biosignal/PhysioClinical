# Score the Modified Fatigue Impact Scale (MFIS)

Sums the twenty-one MFIS items (each 0-4) to a total of 0-84 with
physical (9-item), cognitive (10-item) and psychosocial (2-item)
subscales. A total of 38 or more indicates fatigue.

## Usage

``` r
scoreMFIS(items, ...)
```

## Arguments

- items:

  Named numeric responses (`item01` .. `item21`) or an unnamed vector in
  the instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing = "prorate"`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-84), the three subscale scores and the fatigue
stratum.

## See also

[`scoreFSS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFSS.md),
[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
scoreMFIS(stats::setNames(rep(2, 21), getInstrument("mfis")@items))
#> ClinicalScore [mfis]
#>   total = 42  (fatigued)
#>   subscales:
#>     physical         18
#>     cognitive        20
#>     psychosocial     4
#>   items used: 21, missing = error
```
