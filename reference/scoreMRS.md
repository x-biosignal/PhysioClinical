# Score the modified Rankin Scale (mRS)

Score the modified Rankin Scale (mRS)

## Usage

``` r
scoreMRS(grade, ...)
```

## Arguments

- grade:

  A single global disability grade, 0-6.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
whose total is the grade and whose stratum is the disability label.

## See also

[`scoreNIHSS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreNIHSS.md)

## Examples

``` r
scoreMRS(3)
#> ClinicalScore [mrs]
#>   total = 3  (moderate_disability)
#>   items used: 1, missing = error
```
