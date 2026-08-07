# Clinical outcome analysis: an end-to-end pipeline

`PhysioClinical` turns raw clinical instrument responses into scored,
interpreted, standards-anchored outcomes. This vignette walks a single
patient through the full pipeline: **score → benchmark → classify
response → normative z-score → goal attainment → ICF tagging → FHIR
export.**

## 1. Score an instrument

A `ClinicalScore` is produced from item responses by the data-driven
scoring engine. Here is a Berg Balance Scale (BBS) assessment at
baseline and follow-up.

``` r

baseline_items <- setNames(c(4, 3, 4, 3, 2, 3, 2, 2, 3, 2, 1, 2, 1, 1),
                           sprintf("item%02d", 1:14))
followup_items <- setNames(c(4, 4, 4, 4, 3, 4, 3, 3, 4, 3, 3, 3, 2, 3),
                           sprintf("item%02d", 1:14))

bl <- scoreInstrument("berg", baseline_items, subject_id = "P001",
                      timestamp = "2026-01-10")
fu <- scoreInstrument("berg", followup_items, subject_id = "P001",
                      timestamp = "2026-04-10")
c(baseline = bl@total, followup = fu@total)
#> baseline followup 
#>       33       47
```

If you instead start from a table of already-scored assessments,
[`PhysioIO::readClinicalMetadataCSV()`](https://x-biosignal.r-universe.dev/PhysioIO/reference/readClinicalMetadataCSV.html)
reads the long-format (`subject_id, visit_id, scale_name, scale_score`)
layout into the same workflow.

## 2. Benchmark against published clinimetrics

The bundled clinimetric store returns published MDC/MCID values with
their literature provenance (never fabricated).

``` r

getClinimetric("BBS", "MDC", population = "elderly_baseline_45_56")
#> BBS MDC [elderly_baseline_45_56] = 3.3  (distribution; n=118, doi:10.2340/16501977-0337)
```

## 3. Classify the response (dual MDC-vs-MCID)

[`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)
applies the Beaton dual rule: a change is a *true responder* only when
it exceeds both the MDC (real change beyond measurement error) and the
MCID (clinically important change). We use the Fugl-Meyer upper
extremity (FMA-UE) score, whose store entry carries both a MDC (6.65
points, derived from the Wagner 2008 SEM) and a MCID (4.25 points, Page
2012). Because here the MDC exceeds the MCID, a change can be clinically
important yet still inside measurement error:

``` r

cols <- c("change", "mdc", "mcid", "classification")
# a 6-point gain: past the MCID, but not past the MDC -> measurement error
classifyResponder(baseline = 30, followup = 36, instrument = "FMA-UE",
                  population = "chronic_stroke_minimal",
                  direction = "increase")[, cols]
#>   MDC = 6.65, MCID = 4.25
#> 
#>     true_responder subclinical_change  measurement_error      non_responder 
#>                  0                  0                  1                  0
# a 9-point gain: past both thresholds -> a true responder
classifyResponder(baseline = 30, followup = 39, instrument = "FMA-UE",
                  population = "chronic_stroke_minimal",
                  direction = "increase")[, cols]
#>   MDC = 6.65, MCID = 4.25
#> 
#>     true_responder subclinical_change  measurement_error      non_responder 
#>                  1                  0                  0                  0
```

## 4. Normative z-score

[`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md)
positions an observation against a governed normative reference. The
reference below uses **illustrative** age/sex gait-speed strata for
demonstration.

``` r

ref <- GovernedNormativeReference(
  "demo_gs", "gait", "gait_speed",
  provenance = list(source = "illustrative vignette data"),
  consent = list(status = "public"), license = list(spdx = "CC0-1.0"),
  governance = list(custodian = "demo", access_level = "open"),
  strata_vars = c("age", "sex"),
  model = list(type = "strata", table = data.frame(
    age = c(60, 60, 70, 70), sex = c("M", "F", "M", "F"),
    mean = c(1.30, 1.24, 1.15, 1.10), sd = c(0.20, 0.18, 0.18, 0.17))))

z <- normativeZScore(0.83, ref, covariates = list(age = 70, sex = "M"))
z[c("z", "percentile", "deviation_flag")]
#> $z
#> [1] -1.777778
#> 
#> $percentile
#> [1] 3.772018
#> 
#> $deviation_flag
#> [1] FALSE
```

## 5. Goal Attainment Scaling

``` r

goals <- list(
  defineGoal("Independent standing balance", importance = 3, difficulty = 2),
  defineGoal("Walk 10 m unaided", importance = 3, difficulty = 3))
scoreGAS(goals, attained_levels = c(1, 0))
#> <gas_result> T = 54.91  (2 goal(s), weighted, rho = 0.3)
#>                   description weight attained contribution
#>  Independent standing balance      6        1            6
#>             Walk 10 m unaided      9        0            0
```

## 6. Tag outcomes to the ICF (cross-package)

With `PhysioAnnotationHub`, every instrument links to WHO ICF
categories, and a condition’s published Core Set is available.

``` r

PhysioAnnotationHub::tagICF("berg")
#> [1] "b710" "b755"
head(PhysioAnnotationHub::getCoreSet("Stroke")[, c("icf_code", "category_title")])
#>   icf_code               category_title
#> 1     b110      Consciousness functions
#> 2     b114        Orientation functions
#> 3     b140          Attention functions
#> 4     b144             Memory functions
#> 5     b167 Mental functions of language
#> 6     b730       Muscle power functions
```

## 7. Export to FHIR

Finally, a `ClinicalScore` serialises to an HL7 FHIR R4 `Observation`.

``` r

obs <- toFHIRObservation(fu)
obs$resourceType
#> [1] "Observation"
obs$valueQuantity
#> $value
#> [1] 47
#> 
#> $unit
#> [1] "{score}"
#> 
#> $system
#> [1] "http://unitsofmeasure.org"
#> 
#> $code
#> [1] "{score}"
```

This is the whole arc: from item responses to a standards-compliant,
ICF-anchored, interoperable clinical record.
