# Score a cohort's instrument responses into interop-ready ClinicalScores

Scores a per-subject table of instrument responses into a list of
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
objects, each tagged with its `subject_id`, ready to drive the FHIR /
OMOP / CDISC exporters
([`writeFHIRBundle()`](https://x-biosignal.github.io/PhysioClinical/reference/writeFHIRBundle.md),
[`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md),
[`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md))
directly. The `subject_col` and item columns can come straight from a
cohort's data (e.g. a `PhysioCohort` subject table joined to captured
responses).

## Usage

``` r
scoreCohort(
  responses,
  instrument,
  subject_col = "subject_id",
  timestamp_col = NULL,
  missing = c("error", "prorate", "na")
)
```

## Arguments

- responses:

  A data.frame: one row per subject, with a subject-id column and one
  column per instrument item (columns not matching an item are ignored).

- instrument:

  A
  [ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md)
  or an instrument id (resolved via
  [`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)).

- subject_col:

  Name of the subject-id column (default `"subject_id"`).

- timestamp_col:

  Optional name of a timestamp column stored on each score.

- missing:

  Missing-data policy passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (default `"error"`; use `"prorate"` / `"na"` when only some items are
  present).

## Value

A named list (by subject id) of
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
objects.

## See also

[`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md),
[`writeFHIRBundle()`](https://x-biosignal.github.io/PhysioClinical/reference/writeFHIRBundle.md),
[`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md),
[`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md)

## Examples

``` r
items <- getInstrument("katz_adl")@items
resp <- data.frame(subject_id = c("P01", "P02"),
  stats::setNames(as.data.frame(rbind(rep(1, 6), c(1, 0, 1, 1, 0, 1))), items))
scores <- scoreCohort(resp, "katz_adl")
vapply(scores, function(s) s@total, numeric(1))
#> P01 P02 
#>   6   4 
```
