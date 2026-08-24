# Construct a ClinicalInstrument

Construct a ClinicalInstrument

## Usage

``` r
ClinicalInstrument(
  id,
  name = NA_character_,
  version = NA_character_,
  items,
  item_ranges,
  item_type = "interval",
  subscales = list(),
  aggregation = "sum",
  direction = "higher_better",
  strata = list(),
  item_values = list(),
  item_recode = list(),
  source_ref = NA_character_
)
```

## Arguments

- id, name, version, items, item_ranges, item_type, subscales,
  aggregation, direction, strata, item_values, item_recode, source_ref:

  Instrument specification fields (see the class slots).

## Value

A `ClinicalInstrument`.

## See also

[`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md),
[`registerInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/registerInstrument.md)

## Examples

``` r
ClinicalInstrument(
  id = "toy", name = "Toy scale", items = c("q1", "q2"),
  item_ranges = list(q1 = c(0, 4), q2 = c(0, 4)))
#> ClinicalInstrument 'toy': Toy scale
#>   2 items (interval), aggregation = sum, direction = higher_better
```
