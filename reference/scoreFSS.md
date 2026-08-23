# Score the Fatigue Severity Scale (FSS)

Averages the nine FSS statements (each rated 1 = strongly disagree to 7
= strongly agree) to a mean of 1-7. A mean of 4 or more indicates
clinically significant fatigue.

## Usage

``` r
scoreFSS(items, ...)
```

## Arguments

- items:

  Named numeric responses (`item1` .. `item9`) or an unnamed vector in
  the instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing = "prorate"`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the mean (1-7) and the fatigue stratum.

## See also

[`scoreMFIS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMFIS.md)

## Examples

``` r
scoreFSS(stats::setNames(c(6, 6, 5, 6, 5, 6, 6, 5, 6),
                         getInstrument("fss")@items))
#> ClinicalScore [fss]
#>   total = 5.666667  (significant_fatigue)
#>   items used: 9, missing = error
```
