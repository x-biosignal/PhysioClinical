# Changelog

## PhysioClinical 0.1.0

Initial release as part of the x-biosignal rehabilitation ecosystem
split. This first version establishes the clinical outcome-analysis
package, from instrument scoring through standards-compliant export.

### New Features

- End-to-end clinical outcome pipeline (see the *Clinical outcome
  analysis* vignette): score an instrument, benchmark against published
  clinimetrics, classify the response (dual MDC-vs-MCID), compute a
  normative z-score, score goal attainment, tag to the WHO ICF, and
  export to FHIR.

- Data-driven scoring of validated instruments (Berg, FMA-UE/LE, ARAT,
  NIHSS, mRS, MAS, WMFT, FIM, FAM) and timed performance tests (10mWT,
  6MWT, TUG).

- A clinimetric store of published MDC/MCID/SEM/ICC constants (each with
  a DOI),
  [`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)
  dual responder classification, and governed normative references with
  [`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md).

- Goal Attainment Scaling
  ([`defineGoal()`](https://x-biosignal.github.io/PhysioClinical/reference/defineGoal.md)
  /
  [`scoreGAS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreGAS.md)).

- Interoperability export: FHIR R4 `Observation`
  ([`toFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)),
  OMOP CDM v5.4
  ([`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md)),
  and CDISC SDTM QS / ADaM
  ([`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md)).

- `inst/scripts/validate_com_library.R` reproduces published clinimetric
  reference values from the bundled store.

- Responder classification against the minimal detectable change (MDC):

  - [`mdcResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/mdcResponder.md)
    labels change scores (follow-up minus baseline) as `"improved"`,
    `"stable"`, or `"declined"`, treating a change as a real improvement
    or decline only when it exceeds the measurement noise.
  - The MDC threshold is derived from the standard error of measurement
    (`sem_value`) at a configurable confidence level (default 0.95) via
    [`PhysioCore::mdc()`](https://x-biosignal.r-universe.dev/PhysioCore/reference/mdc.html),
    so classification stays consistent with the shared psychometric
    kernels in the ecosystem.
  - Accepts vectors of change scores for batch classification across a
    cohort.
