# Import a FHIR R4 Observation as a clinical score

Parses an HL7 FHIR R4 `Observation` (as produced by
[`toFHIRObservation`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md))
back into a
[`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md),
the import counterpart of the `to*`/`write*` exporters. The
`instrument_id` and each subscale name are recovered from the bundled
LOINC map (reverse code lookup, then display, then the verbatim text);
the `total` and subscale values come from `valueQuantity` (a
`dataAbsentReason` becomes `NA`); the subject id strips a leading
`"Patient/"`; and the timestamp comes from `effectiveDateTime`.

## Usage

``` r
fromFHIR(observation)
```

## Arguments

- observation:

  A FHIR Observation as a list (a
  [`toFHIRObservation`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)
  result or a parsed jsonlite object), a JSON string, or a path to a
  `.json` file.

## Value

A
[`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md).

## Details

The round-trip is lossy for three slots that
[`toFHIRObservation`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)
does not serialize: `items_used` and `missing_handling` cannot be
recovered, and `stratum` is re-derived from the total only when the
instrument is registered (via
[`getInstrument`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)),
otherwise `NA`.

## See also

[`toFHIRObservation`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md),
[`writeFHIRBundle`](https://x-biosignal.github.io/PhysioClinical/reference/writeFHIRBundle.md)

## Examples

``` r
sc <- scoreInstrument("katz_adl",
  stats::setNames(rep(1, 6), getInstrument("katz_adl")@items),
  subject_id = "P01")
fromFHIR(toFHIRObservation(sc))@total
#> [1] 6
```
