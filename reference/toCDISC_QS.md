# Export clinical scores to a CDISC SDTM QS (Questionnaires) domain

Maps one or more
[`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
objects to a CDISC SDTMIG Questionnaires (QS) domain data frame: the
total and each subscale becomes a QS record. `QSTESTCD`/`QSTEST`/`QSCAT`
come from the packaged controlled-terminology map (`cdisc_ct.csv`); an
unmapped instrument gets a sponsor-defined `QSTESTCD` (upper-cased,
forced to start with a letter, disambiguated against collisions, and
truncated to the SDTM 8-character limit) with a warning. `QSTESTCD`
values in the shipped map are sponsor-defined (`ct_status = "sponsor"`),
not asserted to be published CDISC CT.

## Usage

``` r
toCDISC_QS(
  scores,
  ct_map = NULL,
  studyid = "STUDY",
  usubjid_map = NULL,
  visitnum = 1L,
  visit = NA_character_
)
```

## Arguments

- scores:

  A
  [`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
  or a list of them.

- ct_map:

  Optional data frame overriding the packaged CT map (columns
  `instrument`, `subscale`, `qstestcd`, `qstest`, `qscat`).

- studyid:

  `STUDYID` value (default `"STUDY"`).

- usubjid_map:

  Optional named vector/list mapping `subject_id` to a `USUBJID`;
  otherwise `USUBJID = <studyid>-<subject_id>`.

- visitnum, visit:

  `VISITNUM` / `VISIT` for all records.

## Value

A QS-domain `data.frame` conforming to the SDTMIG column layout.

## References

CDISC SDTMIG QS domain.

## See also

[`toADaM_ADQS()`](https://x-biosignal.github.io/PhysioClinical/reference/toADaM_ADQS.md),
[`toFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md),
[`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md)

## Examples

``` r
sc <- methods::new("ClinicalScore", instrument_id = "fim", total = 90,
                   subscales = c(motor = 60, cognitive = 30),
                   subject_id = "01-001", timestamp = "2026-07-26")
toCDISC_QS(sc)
#>   STUDYID DOMAIN      USUBJID QSSEQ QSTESTCD                 QSTEST
#> 1   STUDY     QS STUDY-01-001     1   FIMTOT        FIM Total Score
#> 2   STUDY     QS STUDY-01-001     2   FIMMOT     FIM Motor Subscale
#> 3   STUDY     QS STUDY-01-001     3   FIMCOG FIM Cognitive Subscale
#>                             QSCAT QSORRES QSORRESU QSSTRESC QSSTRESN QSSTRESU
#> 1 FUNCTIONAL INDEPENDENCE MEASURE      90     <NA>       90       90     <NA>
#> 2 FUNCTIONAL INDEPENDENCE MEASURE      60     <NA>       60       60     <NA>
#> 3 FUNCTIONAL INDEPENDENCE MEASURE      30     <NA>       30       30     <NA>
#>   VISITNUM VISIT      QSDTC
#> 1        1  <NA> 2026-07-26
#> 2        1  <NA> 2026-07-26
#> 3        1  <NA> 2026-07-26
```
