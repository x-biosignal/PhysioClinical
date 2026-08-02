# Export clinical scores to an ADaM BDS (ADQS) data frame

Restructures a QS domain (or scores) into an ADaM Basic Data Structure
analysis data set (one `PARAMCD` per test): `AVAL`/`AVALC` carry the
numeric/character result and `PARCAT1` the questionnaire category.

## Usage

``` r
toADaM_ADQS(x, ...)
```

## Arguments

- x:

  A
  [`ClinicalScore`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md),
  a list of them, or a QS-domain data frame from
  [`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md).

- ...:

  Passed to
  [`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md)
  when `x` is score(s).

## Value

An ADaM BDS `data.frame` (columns `STUDYID`, `USUBJID`, `PARAMCD`,
`PARAM`, `PARCAT1`, `AVAL`, `AVALC`, `AVISIT`, `AVISITN`, `ADT`).

## References

CDISC ADaM Basic Data Structure (BDS).

## See also

[`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md)
