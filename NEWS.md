# PhysioClinical 0.7.0

* `fromFHIR()`: import a FHIR R4 Observation (a `toFHIRObservation()` result, JSON
  string, or `.json` path) back into a `ClinicalScore` — the import counterpart to
  the export-only interop. Recovers instrument id and subscale names via the
  bundled LOINC map, total/subscale values from `valueQuantity` (`dataAbsentReason`
  -> `NA`), subject id (strips `Patient/`) and timestamp; re-derives the stratum
  for a registered instrument. Documented lossy slots: `items_used` and
  `missing_handling` are not recoverable.

# PhysioClinical 0.6.0

* `scoreCohort()`: batch-scores a per-subject table of instrument responses into
  a list of `ClinicalScore` objects tagged with `subject_id`, ready to drive the
  existing FHIR / OMOP / CDISC exporters (`writeFHIRBundle()`, `toOMOP()`,
  `toCDISC_QS()`) from the core data model rather than from hand-built scores.

# PhysioClinical 0.5.0

SF-36 and PROMIS health-status scoring; a general item-recode step in the engine.

* `scoreSF36()`: the SF-36 / RAND 36-Item Health Survey 1.0 — each item is recoded
  to 0-100 and averaged into the eight subscales (physical functioning,
  role-physical, role-emotional, energy/fatigue, emotional well-being, social
  functioning, pain, general health). Norm-based T-scores and the PCS/MCS
  summaries use proprietary weights and are out of scope.
* `scorePROMIS()`: graded-response-model (Samejima) EAP scoring on the PROMIS
  T-score metric (mean 50, SD 10) for any GRM short form; `promisRawToT()` for the
  summed-score-to-T-score table path. No item calibrations are bundled — supply
  the official parameters / conversion tables from HealthMeasures.
* `ClinicalInstrument` gains an optional `item_recode` map (raw response -> scored
  value, applied after validation and before aggregation), so recoded /
  reverse-scored instruments such as the SF-36 are handled by the generic engine.

# PhysioClinical 0.4.0

Range-of-motion (goniometry) reference values.

* `romReference()`: packaged normal active ROM reference angles for the major
  peripheral joints (shoulder, elbow, forearm, wrist, hip, knee, ankle; 25
  motions), the consensus clinical goniometry values (AAOS; Norkin & White).
* `romNormalcy()`: compares a measured joint ROM against the reference angle and,
  optionally, the contralateral side (percent of normal, deficit vs reference,
  deficit vs the other side).
* These are single reference angles, not a distribution: for an age/sex-stratified
  z-score, build a `GovernedNormativeReference()` from a cohort dataset (e.g.
  Soucie et al. 2011) and use `normativeZScore()`. Documented as such (no SD is
  fabricated).

# PhysioClinical 0.3.0

Tier-2 clinical outcome content: cognition, pain, muscle strength, fatigue and
health-related quality of life. Eight validated instruments were added, each as
a bundled YAML specification (auto-registered, discoverable via
`listInstruments()`) plus a typed scoring wrapper delegating to
`scoreInstrument()`, with provenance and interpretation strata.

* Cognition: `scoreMMSE()` (Mini-Mental State Examination, 0-30 with six domain
  subscales) and `scoreMoCA()` (Montreal Cognitive Assessment, 0-30, the <26
  impairment cutoff).
* Pain: `scorePainNRS()` (0-10 Numeric Rating Scale with none/mild/moderate/
  severe bands) and `scoreBPI()` (Brief Pain Inventory severity and interference
  mean subscales).
* Muscle strength: `scoreMRCSum()` (Medical Research Council sum score, 0-60,
  with upper-limb/lower-limb/left/right subscales and the <48 weakness cutoff).
* Fatigue: `scoreFSS()` (Fatigue Severity Scale, mean 1-7, the >=4 cutoff) and
  `scoreMFIS()` (Modified Fatigue Impact Scale, 0-84 with physical/cognitive/
  psychosocial subscales, the >=38 cutoff).
* Health-related quality of life: `scoreEQ5D5L()` (EQ-5D-5L descriptive system
  scored as the 5-25 level-sum score; the country-specific utility index and
  EQ-VAS are out of scope and documented as such).
* Clinimetrics: added the Farrar (2001) NRS pain MCID (~2 points) to the
  MCID/MDC store.

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
