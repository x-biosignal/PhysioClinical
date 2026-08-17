# Score the Barthel Index (basic activities of daily living)

The Barthel Index rates ten basic ADL domains on their conventional
weighted scale (steps of 5; transfers and mobility to 15) for a total of
0-100, higher being more independent.

## Usage

``` r
scoreBarthel(items, ...)
```

## Arguments

- items:

  Named numeric responses on the weighted per-item scale (e.g.
  `feeding = 10`, `bathing = 5`, `transfers = 15`), or an unnamed vector
  in the instrument's item order. Allowed values are the conventional
  weights (0/5/10, and 0/5/10/15 for transfers and mobility).

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing`, `subject_id`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-100) and the dependence stratum (total / severe /
moderate / slight dependence / independent).

## See also

[`scoreKatz()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreKatz.md),
[`scoreLawton()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreLawton.md),
[`raschAnalyze()`](https://x-biosignal.github.io/PhysioClinical/reference/raschAnalyze.md)

## Examples

``` r
scoreBarthel(stats::setNames(
  c(10, 5, 5, 10, 10, 10, 10, 15, 15, 10), getInstrument("barthel")@items))
#> ClinicalScore [barthel]
#>   total = 100  (independent)
#>   items used: 10, missing = error
```
