# Score the Action Research Arm Test (ARAT)

Score the Action Research Arm Test (ARAT)

## Usage

``` r
scoreARAT(items, ...)
```

## Arguments

- items:

  Named numeric responses (0-3 per item) for the 19 ARAT items.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-57) and the grasp/grip/pinch/ gross-movement subscale
scores.

## See also

[`scoreFMAUE()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFMAUE.md)
