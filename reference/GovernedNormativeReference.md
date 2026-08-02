# Construct a governed normative reference

Construct a governed normative reference

## Usage

``` r
GovernedNormativeReference(
  id,
  modality,
  metric,
  version = "1.0.0",
  provenance = list(),
  consent = list(),
  license = list(),
  governance = list(),
  strata_vars = character(0),
  model = list(),
  n = NA_real_
)
```

## Arguments

- id, modality, metric:

  Identifying strings.

- version:

  Semantic version (default `"1.0.0"`).

- provenance, consent, license, governance:

  Governance lists (see
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md));
  `provenance$source`, `consent$status` and `license$spdx` are required.

- strata_vars:

  Character vector of stratification variables.

- model:

  List holding the normative model (stratified mean/sd table or LMS
  coefficients).

- n:

  Reference sample size.

## Value

A validated
[`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md).

## See also

[`registerNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/registerNormative.md),
[`validateNormativeManifest()`](https://x-biosignal.github.io/PhysioClinical/reference/validateNormativeManifest.md)

## Examples

``` r
GovernedNormativeReference(
  id = "gait_speed_adult", modality = "gait", metric = "gait_speed",
  version = "1.0.0",
  provenance = list(source = "Bohannon 1997", doi = "10.1093/ageing/26.1.15"),
  consent = list(status = "public_aggregate"),
  license = list(spdx = "CC-BY-4.0", redistribution_ok = TRUE),
  governance = list(custodian = "Matsui Lab", access_level = "open"),
  strata_vars = c("age", "sex"),
  model = list(type = "strata",
               table = data.frame(age = 70, sex = "M", mean = 1.3, sd = 0.2)),
  n = 230)
#> <GovernedNormativeReference> gait_speed_adult  v1.0.0
#>   modality/metric: gait / gait_speed
#>   n = 230   strata: age, sex
#>   provenance: Bohannon 1997 (doi:10.1093/ageing/26.1.15)
#>   consent:    public_aggregate   ethics: NA
#>   license:    CC-BY-4.0   redistribute: TRUE
#>   governance: Matsui Lab   access: open
```
