# Score item responses against a clinical instrument

Validates a set of item responses against a
[ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md),
aggregates them into the total and subscale scores under the chosen
missing-data policy, and assigns the interpretation stratum.

## Usage

``` r
scoreInstrument(
  instrument,
  items,
  missing = c("error", "prorate", "na"),
  subject_id = NA_character_,
  timestamp = NA_character_
)
```

## Arguments

- instrument:

  A
  [ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md),
  or an instrument id resolved via
  [`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md).

- items:

  A named numeric vector (item id -\> response), a one-row data.frame,
  or an unnamed vector in the instrument's item order.

- missing:

  Missing-data policy: `"error"` (default; any missing item is an
  error), `"prorate"` (scale the observed items up to the full count) or
  `"na"` (return `NA` for any score with a missing item).

- subject_id:

  Optional subject identifier stored on the result.

- timestamp:

  Optional timestamp stored on the result.

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md).

## See also

[ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md),
[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
inst <- ClinicalInstrument(
  id = "toy", items = c("q1", "q2", "q3"),
  item_ranges = list(q1 = c(0, 4), q2 = c(0, 4), q3 = c(0, 4)))
scoreInstrument(inst, c(q1 = 2, q2 = 3, q3 = 4))
#> ClinicalScore [toy]
#>   total = 9
#>   items used: 3, missing = error
```
