# Clinical instrument specification

A declarative specification of a clinical outcome measure: its items,
their admissible ranges and measurement level, its subscales, how items
aggregate into scores, the direction of clinical benefit, and the
interpretation strata.

## Usage

``` r
# S4 method for class 'ClinicalInstrument'
show(object)
```

## Arguments

- object:

  A `ClinicalInstrument`.

## Slots

- `id`:

  Short unique identifier (e.g. `"berg"`).

- `name`:

  Human-readable name.

- `version`:

  Specification version string.

- `items`:

  Character vector of item identifiers, in order.

- `item_ranges`:

  Named list; each entry a length-2 numeric `c(min, max)` for the
  corresponding item.

- `item_type`:

  Character vector (recycled to the item count) of `"interval"` or
  `"ordinal"`.

- `subscales`:

  Named list mapping each subscale name to a character vector of its
  item identifiers; length 0 for single-scale instruments.

- `aggregation`:

  `"sum"` or `"mean"`.

- `direction`:

  `"higher_better"` or `"higher_worse"`.

- `strata`:

  List of interpretation bands, each a list with `label`, `lower` and
  `upper`.

- `item_values`:

  Optional named list; for an item with a discrete (possibly
  non-integer) admissible value set - e.g. the Modified Ashworth `1+` =
  1.5 - the numeric vector of allowed values. Items absent from the list
  are validated only against `item_ranges` / `item_type`.

- `source_ref`:

  Citation / provenance string.
