# Export clinical scores to OMOP CDM v5.4 tables

Maps one or more
[`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
objects to OMOP Common Data Model v5.4 `MEASUREMENT` and `OBSERVATION`
rows. The total and each subscale become a row, routed to `MEASUREMENT`
or `OBSERVATION` by the concept map's `domain_id`. Concept ids are
looked up in the packaged `omop_concept_map.csv`; an unmapped instrument
yields `measurement_concept_id = 0` (the OMOP "No matching concept")
with a warning. No Athena concept ids are fabricated — the shipped map
leaves them blank; supply a site `concept_map` to populate them.

## Usage

``` r
toOMOP(scores, concept_map = NULL, person_map = NULL, type_concept_id = 0L)
```

## Arguments

- scores:

  A
  [`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
  or a list of them.

- concept_map:

  Optional data frame overriding the packaged concept map (columns
  `instrument`, `subscale`, `domain_id`, `measurement_concept_id`,
  `unit_concept_id`).

- person_map:

  Optional named vector/list mapping `subject_id` to an integer
  `person_id`. When absent, a plain positive-integer `subject_id`
  (matching `"^[0-9]+$"`) is used directly; any other id is left as `NA`
  with a warning.

- type_concept_id:

  Integer `*_type_concept_id` for provenance (default `0L` = "No
  matching concept"); set to your site's type concept (e.g. EHR).

## Value

A list with `MEASUREMENT` and `OBSERVATION` data frames conforming to
the OMOP CDM v5.4 column layout.

## References

OHDSI OMOP CDM v5.4 (MEASUREMENT, OBSERVATION).

## See also

[`writeOMOPTables()`](https://x-biosignal.github.io/PhysioClinical/reference/writeOMOPTables.md),
[`toFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)

## Examples

``` r
sc <- methods::new("ClinicalScore", instrument_id = "berg", total = 45,
                   subject_id = "1001", timestamp = "2026-07-26T09:00:00Z")
suppressWarnings(toOMOP(sc))
#> $MEASUREMENT
#>  [1] measurement_id                person_id                    
#>  [3] measurement_concept_id        measurement_date             
#>  [5] measurement_datetime          measurement_type_concept_id  
#>  [7] value_as_number               value_as_concept_id          
#>  [9] unit_concept_id               measurement_source_value     
#> [11] measurement_source_concept_id unit_source_value            
#> [13] value_source_value           
#> <0 rows> (or 0-length row.names)
#> 
#> $OBSERVATION
#>   observation_id person_id observation_concept_id observation_date
#> 1              1      1001                      0       2026-07-26
#>   observation_datetime observation_type_concept_id value_as_number
#> 1  2026-07-26 09:00:00                           0              45
#>   value_as_string value_as_concept_id unit_concept_id observation_source_value
#> 1            <NA>                  NA               0                     berg
#>   observation_source_concept_id unit_source_value
#> 1                             0           {score}
#> 
```
