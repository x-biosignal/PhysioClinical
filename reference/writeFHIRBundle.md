# Write a FHIR Bundle of clinical-score Observations

Write a FHIR Bundle of clinical-score Observations

## Usage

``` r
writeFHIRBundle(scores, path)
```

## Arguments

- scores:

  A
  [`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md),
  an `"fhir_observation"`, or a list of either.

- path:

  Output `.json` path.

## Value

`path`, invisibly.

## See also

[`toFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)
