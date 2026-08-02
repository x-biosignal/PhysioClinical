# Governed normative reference

An S4 container for a normative reference distribution together with the
governance metadata a clinical artifact must carry: provenance, consent,
license and custodianship. Validity requires the provenance source,
consent status and license identifier to be present, so an ungoverned
reference cannot be constructed.

## Slots

- `id`:

  Stable artifact identifier.

- `modality`:

  Signal modality (e.g. `"gait"`, `"hrv"`).

- `metric`:

  The normed quantity (e.g. `"gait_speed"`).

- `version`:

  Semantic version string `"x.y.z"`.

- `provenance`:

  List with at least `source`; optionally `doi`, `collection_date`.

- `consent`:

  List with at least `status`; optionally `ethics_id`.

- `license`:

  List with at least `spdx`; optionally `redistribution_ok`.

- `governance`:

  List with `custodian` and `access_level`.

- `strata_vars`:

  Character vector of stratification variables (e.g. `c("age", "sex")`).

- `model`:

  List holding the normative model — either a stratified mean/sd table
  or LMS (`lambda`/`mu`/`sigma`) coefficients.

- `n`:

  Reference sample size.
