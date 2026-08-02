# Score the Functional Assessment Measure (FIM+FAM)

Score the Functional Assessment Measure (FIM+FAM)

## Usage

``` r
scoreFAM(items, ...)
```

## Arguments

- items:

  Named numeric responses (1-7 per item) for the 30 FIM+FAM items.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (30-210) and the combined `motor` (16 items) and
`cognitive` (14 items) subscale scores.

## See also

[`scoreFIM()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFIM.md)
