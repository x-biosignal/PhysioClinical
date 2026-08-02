# Convert a ClinicalScore to a one-row data.frame

Convert a ClinicalScore to a one-row data.frame

## Usage

``` r
# S3 method for class 'ClinicalScore'
as.data.frame(x, ..., stringsAsFactors = FALSE)
```

## Arguments

- x:

  A
  [ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md).

- ...:

  Ignored.

- stringsAsFactors:

  Ignored (kept for the S3 generic signature).

## Value

A one-row data.frame with the total, each subscale, the stratum and the
metadata columns.
