# Package index

## Instrument scoring

Data-driven scoring of validated clinical outcome measures.

- [`ClinicalInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md)
  : Construct a ClinicalInstrument
- [`show(`*`<ClinicalInstrument>`*`)`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument-class.md)
  : Clinical instrument specification
- [`show(`*`<ClinicalScore>`*`)`](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
  : Clinical score result
- [`as.data.frame(`*`<ClinicalScore>`*`)`](https://x-biosignal.github.io/PhysioClinical/reference/as.data.frame.ClinicalScore.md)
  : Convert a ClinicalScore to a one-row data.frame
- [`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)
  : Retrieve a registered clinical instrument
- [`listInstruments()`](https://x-biosignal.github.io/PhysioClinical/reference/listInstruments.md)
  : List available clinical instruments
- [`registerInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/registerInstrument.md)
  : Register a clinical instrument
- [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  : Score item responses against a clinical instrument
- [`scoreBerg()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreBerg.md)
  : Score the Berg Balance Scale (BBS)
- [`scoreFMAUE()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFMAUE.md)
  : Score the Fugl-Meyer Assessment, Upper Extremity (FMA-UE)
- [`scoreFMALE()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFMALE.md)
  : Score the Fugl-Meyer Assessment, Lower Extremity (FMA-LE)
- [`scoreARAT()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreARAT.md)
  : Score the Action Research Arm Test (ARAT)
- [`scoreNIHSS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreNIHSS.md)
  : Score the NIH Stroke Scale (NIHSS)
- [`scoreMRS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMRS.md)
  : Score the modified Rankin Scale (mRS)
- [`scoreMAS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMAS.md)
  : Score a Modified Ashworth Scale (MAS) rating
- [`masLevelLabel()`](https://x-biosignal.github.io/PhysioClinical/reference/masLevelLabel.md)
  : Modified Ashworth Scale level label for a value
- [`scoreWMFT()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreWMFT.md)
  : Score the Wolf Motor Function Test functional-ability scale
  (WMFT-FAS)
- [`wmftMedianTime()`](https://x-biosignal.github.io/PhysioClinical/reference/wmftMedianTime.md)
  : Median WMFT performance time
- [`scoreFIM()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFIM.md)
  : Score the Functional Independence Measure (FIM)
- [`scoreFAM()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFAM.md)
  : Score the Functional Assessment Measure (FIM+FAM)

## Timed performance tests

Gait- and mobility-derived timed tests.

- [`score10MWT()`](https://x-biosignal.github.io/PhysioClinical/reference/score10MWT.md)
  : Score a 10-metre walk test (10mWT)
- [`score6MWT()`](https://x-biosignal.github.io/PhysioClinical/reference/score6MWT.md)
  : Score a 6-minute walk test (6MWT)
- [`scoreTUG()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreTUG.md)
  : Score a Timed Up and Go test (TUG)

## Clinimetrics and responder analysis

Published MDC/MCID constants and dual responder classification.

- [`getClinimetric()`](https://x-biosignal.github.io/PhysioClinical/reference/getClinimetric.md)
  : Look up a per-instrument clinimetric constant
- [`listClinimetrics()`](https://x-biosignal.github.io/PhysioClinical/reference/listClinimetrics.md)
  : List available clinimetric constants
- [`estimateMDC()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMDC.md)
  : Distribution-based Minimal Detectable Change from test-retest data
- [`estimateMCID_distribution()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMCID_distribution.md)
  : Distribution-based MCID (fraction-of-SD rule)
- [`estimateMCID_anchor()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMCID_anchor.md)
  : Anchor-based MCID
- [`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)
  [`summary(`*`<responder_classification>`*`)`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)
  : Dual MDC-vs-MCID responder classification
- [`mdcResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/mdcResponder.md)
  : Classify change scores against the minimal detectable change (MDC)

## Normative references

Governed normative databases and deviation scoring.

- [`GovernedNormativeReference()`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference.md)
  : Construct a governed normative reference
- [`GovernedNormativeReference-class`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md)
  : Governed normative reference
- [`show(`*`<GovernedNormativeReference>`*`)`](https://x-biosignal.github.io/PhysioClinical/reference/show-GovernedNormativeReference-method.md)
  : Show a normative reference (surfacing its governance)
- [`registerNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/registerNormative.md)
  : Register a normative reference in the versioned registry
- [`getNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/getNormative.md)
  : Retrieve a normative reference from the registry
- [`listNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/listNormative.md)
  : List registered normative references
- [`validateNormativeManifest()`](https://x-biosignal.github.io/PhysioClinical/reference/validateNormativeManifest.md)
  : Validate a normative-artifact governance manifest
- [`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md)
  : Normative z-score / percentile for an observation
- [`normativeDeviation()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeDeviation.md)
  : Batch normative deviation over a metric table
- [`matchStratum()`](https://x-biosignal.github.io/PhysioClinical/reference/matchStratum.md)
  : Match the normative stratum for a set of covariates

## Goal Attainment Scaling

- [`defineGoal()`](https://x-biosignal.github.io/PhysioClinical/reference/defineGoal.md)
  : Define a Goal Attainment Scaling goal
- [`scoreGAS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreGAS.md)
  : Score Goal Attainment Scaling (GAS T-score)
- [`gasSummary()`](https://x-biosignal.github.io/PhysioClinical/reference/gasSummary.md)
  : Tabulate a GAS result

## Interoperability export

FHIR, OMOP CDM, and CDISC SDTM/ADaM export of clinical scores.

- [`toFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/toFHIRObservation.md)
  : Export a clinical score as a FHIR R4 Observation
- [`writeFHIRBundle()`](https://x-biosignal.github.io/PhysioClinical/reference/writeFHIRBundle.md)
  : Write a FHIR Bundle of clinical-score Observations
- [`validateFHIRObservation()`](https://x-biosignal.github.io/PhysioClinical/reference/validateFHIRObservation.md)
  : Validate a FHIR Observation against the bundled JSON schema
- [`toOMOP()`](https://x-biosignal.github.io/PhysioClinical/reference/toOMOP.md)
  : Export clinical scores to OMOP CDM v5.4 tables
- [`writeOMOPTables()`](https://x-biosignal.github.io/PhysioClinical/reference/writeOMOPTables.md)
  : Write OMOP CDM tables to CSV files
- [`toCDISC_QS()`](https://x-biosignal.github.io/PhysioClinical/reference/toCDISC_QS.md)
  : Export clinical scores to a CDISC SDTM QS (Questionnaires) domain
- [`toADaM_ADQS()`](https://x-biosignal.github.io/PhysioClinical/reference/toADaM_ADQS.md)
  : Export clinical scores to an ADaM BDS (ADQS) data frame
