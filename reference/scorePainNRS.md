# Score a Pain Numeric Rating Scale (0-10)

A single 0-10 pain-intensity rating, banded into the conventional none /
mild / moderate / severe strata. An equivalent 0-100 mm Visual Analogue
Scale measures the same construct on a wider range.

## Usage

``` r
scorePainNRS(items, ...)
```

## Arguments

- items:

  The pain rating: a length-1 numeric, or a named vector
  `c(pain_intensity = x)`.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `subject_id`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the rating (0-10) and its severity stratum.

## See also

[`scoreBPI()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreBPI.md)

## Examples

``` r
scorePainNRS(c(pain_intensity = 6))
#> ClinicalScore [pain_nrs]
#>   total = 6  (moderate)
#>   items used: 1, missing = error
```
