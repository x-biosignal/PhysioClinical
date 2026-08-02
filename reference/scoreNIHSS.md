# Score the NIH Stroke Scale (NIHSS)

Score the NIH Stroke Scale (NIHSS)

## Usage

``` r
scoreNIHSS(items, ...)
```

## Arguments

- items:

  Named numeric responses for the 15 NIHSS components (each within its
  own range).

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-42) and the severity band (no stroke / minor /
moderate / moderate-to-severe / severe).

## See also

[`scoreMRS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMRS.md)
