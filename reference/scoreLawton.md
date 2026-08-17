# Score the Lawton-Brody IADL scale (instrumental ADL)

Eight instrumental-ADL domains of independent community living
(telephone, shopping, food preparation, housekeeping, laundry,
transportation, medication, finances), each dichotomised independent (1)
/ dependent (0), summed to a 0-8 count. Lawton & Brody define no
total-score severity bands, so the returned stratum is `NA`.

## Usage

``` r
scoreLawton(items, ...)
```

## Arguments

- items:

  Named numeric responses (0/1 per domain) or an unnamed vector in the
  instrument's item order. For the abbreviated male version, omit the
  food-preparation, housekeeping and laundry items and use
  `missing = "na"`.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-8).

## See also

[`scoreBarthel()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreBarthel.md),
[`scoreKatz()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreKatz.md),
[`raschAnalyze()`](https://x-biosignal.github.io/PhysioClinical/reference/raschAnalyze.md)

## Examples

``` r
scoreLawton(stats::setNames(rep(1, 8), getInstrument("lawton_iadl")@items))
#> ClinicalScore [lawton_iadl]
#>   total = 8
#>   items used: 8, missing = error
```
