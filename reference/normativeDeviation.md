# Batch normative deviation over a metric table

Applies
[`normativeZScore`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md)
to every row of a metric table: each row supplies a `value` plus the
covariate columns named by the reference's `strata_vars`.

## Usage

``` r
normativeDeviation(metric_table, ref, deviation_z = 2)
```

## Arguments

- metric_table:

  A `data.frame` with a `value` column and one column per `ref`
  stratification variable.

- ref:

  A
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md).

- deviation_z:

  Deviation-flag threshold (see
  [`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md)).

## Value

`metric_table` with added `z`, `percentile`, `deviation_flag` and
`extrapolation` columns.

## See also

[`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md)
