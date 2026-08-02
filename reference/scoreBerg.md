# Score the Berg Balance Scale (BBS)

Score the Berg Balance Scale (BBS)

## Usage

``` r
scoreBerg(items, ...)
```

## Arguments

- items:

  Named numeric responses (0-4 per item) for the 14 Berg items.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-56) and the fall-risk stratum.

## See also

[`scoreFMALE()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFMALE.md)
