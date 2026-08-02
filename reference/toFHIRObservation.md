# Export a clinical score as a FHIR R4 Observation

Serializes a
[`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
into an HL7 FHIR R4 `Observation` resource (as a jsonlite-ready list): a
survey-category Observation whose `code` uses the LOINC map (falling
back to a text-only code), the total as `valueQuantity`, and each
subscale as a `component`. Provenance can be attached via `derivedFrom`.

## Usage

``` r
toFHIRObservation(
  score,
  subject = NULL,
  effectiveDateTime = NULL,
  derivedFrom = NULL
)
```

## Arguments

- score:

  A
  [`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md).

- subject:

  Subject reference (e.g. `"Patient/123"`); used verbatim. Defaults to
  the score's `subject_id`: a bare id becomes `"Patient/<id>"`, while an
  id that is already a reference (contains a `"/"` or a `urn:`/URL
  scheme) is used as-is.

- effectiveDateTime:

  ISO-8601 datetime; defaults to the score's timestamp.

- derivedFrom:

  Optional character vector of source references.

## Value

A `"fhir_observation"` list.

## References

HL7 FHIR R4 Observation; LOINC.

## See also

[`writeFHIRBundle()`](https://x-biosignal.github.io/PhysioClinical/reference/writeFHIRBundle.md),
[`validateFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/validateFHIRObservation.md)

## Examples

``` r
sc <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
                   subject_id = "P01", timestamp = "2026-07-26T09:00:00Z")
toFHIRObservation(sc)
#> <fhir_observation> Observation/final
#>   code:    Berg Balance Scale total score 
#>   subject: Patient/P01 
#>   value:   45 {score} 
```
