# Validate a FHIR Observation against the bundled JSON schema

Validate a FHIR Observation against the bundled JSON schema

## Usage

``` r
validateFHIRObservation(obs)
```

## Arguments

- obs:

  An `"fhir_observation"` (or a list).

## Value

`TRUE` if valid; otherwise `FALSE` with the validation errors as an
attribute (requires jsonvalidate).

## See also

[`toFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)
