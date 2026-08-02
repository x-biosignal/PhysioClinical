# Write OMOP CDM tables to CSV files

Writes each non-empty table from
[`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md)
to `<path>/<table>.csv` (lower-cased, e.g. `measurement.csv`), following
the one-file-per-table OMOP convention.

## Usage

``` r
writeOMOPTables(tables, path)
```

## Arguments

- tables:

  A
  [`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md),
  a list of them, or the list returned by
  [`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md).

- path:

  Output directory (created if needed).

## Value

A character vector of written file paths, invisibly.

## See also

[`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md)
