# Score a Modified Ashworth Scale (MAS) rating

Accepts a MAS rating as its ordinal level label (`"0"`, `"1"`, `"1+"`,
`"2"`, `"3"`, `"4"`) or the equivalent number, mapping `"1+"` to 1.5 for
arithmetic while preserving the label. Rate one muscle group per call.

## Usage

``` r
scoreMAS(rating, ...)
```

## Arguments

- rating:

  A single MAS level label or number.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
whose total is the numeric MAS value; the ordinal label is recovered
with
[`masLevelLabel()`](https://x-biosignal.github.io/PhysioClinical/reference/masLevelLabel.md).

## See also

[`masLevelLabel()`](https://x-biosignal.github.io/PhysioClinical/reference/masLevelLabel.md)

## Examples

``` r
scoreMAS("1+")
#> ClinicalScore [mas]
#>   total = 1.5
#>   items used: 1, missing = error
```
