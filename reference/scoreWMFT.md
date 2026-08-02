# Score the Wolf Motor Function Test functional-ability scale (WMFT-FAS)

Score the Wolf Motor Function Test functional-ability scale (WMFT-FAS)

## Usage

``` r
scoreWMFT(fas, ...)
```

## Arguments

- fas:

  Named numeric responses (0-5 per task) for the 15 functional tasks.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
whose total is the mean functional-ability score.

## See also

[`wmftMedianTime()`](https://x-biosignal.github.io/PhysioClinical/reference/wmftMedianTime.md)
