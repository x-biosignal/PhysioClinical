# PhysioClinical 0.2.0

ADL/IADL instruments and interval (Rasch) analysis.

* `scoreBarthel()`, `scoreKatz()`, `scoreLawton()`: bundled Barthel Index, Katz
  ADL and Lawton-Brody IADL instruments, with provenance and interpretation
  strata.
* `raschRecode()` / `raschAnalyze()`: interval (Rasch) analysis of an ordinal
  instrument via PhysioAppKit -- item difficulty hierarchy, category
  diagnostics, item fit, separation reliability and the raw-to-interval
  conversion.
* `equateScores()` / `applyEquating()`: equipercentile and linear score
  crosswalks between scales (e.g. Barthel <-> FIM) from a linking sample.
* `raschResponder()`: MDC / responder classification on the Rasch interval
  scale, driving `mdcResponder()` and `classifyResponder()` from the model's own
  standard error.


# PhysioClinical 0.1.0

Initial release as part of the x-biosignal rehabilitation ecosystem split.
This first version establishes the clinical outcome-analysis package, from
instrument scoring through standards-compliant export.

## New Features

- End-to-end clinical outcome pipeline (see the *Clinical outcome analysis*
  vignette): score an instrument, benchmark against published clinimetrics,
  classify the response (dual MDC-vs-MCID), compute a normative z-score, score
  goal attainment, tag to the WHO ICF, and export to FHIR.
- Data-driven scoring of validated instruments (Berg, FMA-UE/LE, ARAT, NIHSS,
  mRS, MAS, WMFT, FIM, FAM) and timed performance tests (10mWT, 6MWT, TUG).
- A clinimetric store of published MDC/MCID/SEM/ICC constants (each with a DOI),
  `classifyResponder()` dual responder classification, and governed normative
  references with `normativeZScore()`.
- Goal Attainment Scaling (`defineGoal()` / `scoreGAS()`).
- Interoperability export: FHIR R4 `Observation` (`toFHIRObservation()`), OMOP
  CDM v5.4 (`toOMOP()`), and CDISC SDTM QS / ADaM (`toCDISC_QS()`).
- `inst/scripts/validate_com_library.R` reproduces published clinimetric
  reference values from the bundled store.

- Responder classification against the minimal detectable change (MDC):
  - `mdcResponder()` labels change scores (follow-up minus baseline) as
    `"improved"`, `"stable"`, or `"declined"`, treating a change as a real
    improvement or decline only when it exceeds the measurement noise.
  - The MDC threshold is derived from the standard error of measurement
    (`sem_value`) at a configurable confidence level (default 0.95) via
    `PhysioCore::mdc()`, so classification stays consistent with the shared
    psychometric kernels in the ecosystem.
  - Accepts vectors of change scores for batch classification across a
    cohort.
