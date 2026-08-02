# Tabulate a GAS result

Tabulate a GAS result

## Usage

``` r
gasSummary(object, ...)
```

## Arguments

- object:

  A `"gas_result"` from
  [`scoreGAS`](https://x-biosignal.github.io/PhysioClinical/reference/scoreGAS.md).

- ...:

  Unused.

## Value

A `data.frame` with one row per goal (description, ICF tag, weight,
attained level and its weighted contribution) plus the T-score as an
attribute.

## See also

[`scoreGAS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreGAS.md)
