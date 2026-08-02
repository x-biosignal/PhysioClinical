# Clinical score result

The result of scoring a set of item responses against a
[ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md).

## Usage

``` r
# S4 method for class 'ClinicalScore'
show(object)
```

## Arguments

- object:

  A `ClinicalScore`.

## Slots

- `instrument_id`:

  Identifier of the scoring instrument.

- `total`:

  Total score (or `NA` if unresolved under the missing policy).

- `subscales`:

  Named numeric vector of subscale scores.

- `stratum`:

  Interpretation stratum label the total falls in (or `NA`).

- `items_used`:

  Character vector of the item identifiers actually scored.

- `missing_handling`:

  The missing-data policy applied.

- `timestamp`:

  Optional character timestamp.

- `subject_id`:

  Optional subject identifier.
