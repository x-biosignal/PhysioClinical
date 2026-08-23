# Score the EQ-5D-5L descriptive system (level-sum score)

Sums the five EQ-5D-5L dimension levels (1 = no problems to 5 = extreme
problems / unable) to a level-sum score of 5-25, higher indicating worse
health. The utility index requires a country-specific value set and is
not computed here; the EQ-VAS (0-100) is a separate rating.

## Usage

``` r
scoreEQ5D5L(items, ...)
```

## Arguments

- items:

  Named numeric levels (e.g. `mobility = 2`, `pain_discomfort = 3`) or
  an unnamed vector in the instrument's item order (mobility, self-care,
  usual activities, pain/discomfort, anxiety/depression).

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the level-sum score (5-25).

## See also

[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
scoreEQ5D5L(c(mobility = 2, self_care = 1, usual_activities = 2,
              pain_discomfort = 3, anxiety_depression = 2))
#> ClinicalScore [eq5d5l]
#>   total = 10
#>   items used: 5, missing = error
```
