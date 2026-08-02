# Score the Functional Independence Measure (FIM)

Score the Functional Independence Measure (FIM)

## Usage

``` r
scoreFIM(items, ...)
```

## Arguments

- items:

  Named numeric responses (1-7 per item) for the 18 FIM items.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (18-126) and subscale scores for the six FIM domains
(self-care, sphincter, transfers, locomotion, communication, social
cognition) plus the combined `motor` (13 items) and `cognitive` (5
items) scores.

## See also

[`scoreFAM()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFAM.md)

## Examples

``` r
scoreFIM(stats::setNames(rep(4, 18), getInstrument("fim")@items))
#> ClinicalScore [fim]
#>   total = 72
#>   subscales:
#>     self_care        24
#>     sphincter        8
#>     transfers        12
#>     locomotion       8
#>     communication    8
#>     social_cognition 12
#>     motor            52
#>     cognitive        20
#>   items used: 18, missing = error
```
