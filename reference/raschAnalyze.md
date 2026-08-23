# Rasch (interval) analysis of a clinical ADL/IADL instrument

Fits a polytomous Rasch model to a cohort's responses on a registered
instrument and returns the psychometric summary that published ADL/IADL
analyses report: the item difficulty hierarchy, category threshold
ordering (with disordered-threshold flags), person and item measures on
an interval (logit) scale, item fit (infit/outfit), person/item
separation reliability, and the raw-score to interval-measure
conversion. The Partial Credit Model is the default (it accommodates the
Barthel Index's mixed item lengths); pass `model = "RSM"` for a
uniform-format scale.

## Usage

``` r
raschAnalyze(instrument, responses, model = c("PCM", "RSM"), ...)
```

## Arguments

- instrument:

  A
  [ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md)
  or an instrument id (e.g. `"barthel"`, `"lawton_iadl"`).

- responses:

  A persons x items matrix or data.frame of responses on the
  instrument's native scale (see
  [`raschRecode()`](https://x-biosignal.github.io/PhysioClinical/reference/raschRecode.md)).

- model:

  `"PCM"` (default) or `"RSM"`.

- ...:

  Passed to
  [`PhysioAppKit::pcm_measure()`](https://x-biosignal.github.io/PhysioAppKit/reference/pcm_measure.html).

## Value

The `poly_rasch` fit (see
[`PhysioAppKit::pcm_measure()`](https://x-biosignal.github.io/PhysioAppKit/reference/pcm_measure.html))
with an added class `clin_rasch` and extra fields: `instrument` (id),
`item_hierarchy` (items ordered hardest-to-easiest by calibrated
location) and `recoded` (the category matrix analysed).

## Details

Requires the suggested package PhysioAppKit (the domain-neutral engine).

## See also

[`raschRecode()`](https://x-biosignal.github.io/PhysioClinical/reference/raschRecode.md),
[`scoreBarthel()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreBarthel.md),
[`PhysioAppKit::pcm_measure()`](https://x-biosignal.github.io/PhysioAppKit/reference/pcm_measure.html)

## Examples

``` r
# \donttest{
set.seed(1)
items <- getInstrument("barthel")@items
# a small synthetic cohort of weighted Barthel responses
resp <- t(replicate(50, {
  ability <- stats::rnorm(1)
  vapply(c(2, 1, 1, 2, 2, 2, 2, 3, 3, 2), function(m)
    c(0, 5, 10, 15)[min(m, max(0, round(ability + m / 2))) + 1], numeric(1))
}))
colnames(resp) <- items
if (requireNamespace("PhysioAppKit", quietly = TRUE)) {
  fit <- raschAnalyze("barthel", resp)
  fit$item_hierarchy
}
#>          item   location        se      infit     outfit disordered
#> 1     bathing  0.5295996 0.8043889 0.09322405 0.04509349      FALSE
#> 2    grooming  0.5295996 0.8043889 0.09322405 0.04509349      FALSE
#> 3   transfers  0.2249286 0.5335115 0.11378499 0.10444891      FALSE
#> 4    mobility  0.2249286 0.5335115 0.11378499 0.10444891      FALSE
#> 5     feeding -0.2007309 0.6806820 0.06327283 0.05849089      FALSE
#> 6    dressing -0.2007309 0.6806820 0.06327283 0.05849089      FALSE
#> 7      bowels -0.2007309 0.6806820 0.06327283 0.05849089      FALSE
#> 8     bladder -0.2007309 0.6806820 0.06327283 0.05849089      FALSE
#> 9  toilet_use -0.2007309 0.6806820 0.06327283 0.05849089      FALSE
#> 10     stairs -0.2007309 0.6806820 0.06327283 0.05849089      FALSE
# }
```
