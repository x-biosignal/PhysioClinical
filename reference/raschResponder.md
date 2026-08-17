# Responder analysis of pre-to-post change on the Rasch interval scale

Classifies each person's change between two occasions using interval
(logit) measures from
[`raschAnalyze()`](https://x-biosignal.github.io/PhysioClinical/reference/raschAnalyze.md)
/ `PhysioAppKit::pcm_measure()`. The Rasch model's own standard errors
give a distribution-free standard error of measurement and hence the
Minimal Detectable Change; the pre/post change is then run through
[`mdcResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/mdcResponder.md)
(reliable change) and, when an MCID on the logit scale is supplied,
[`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)
(the MDC x MCID framework).

## Usage

``` r
raschResponder(
  pre,
  post,
  mcid = NULL,
  confidence = 0.95,
  direction = c("increase", "decrease")
)
```

## Arguments

- pre, post:

  Baseline and follow-up measures: a `poly_rasch` fit, a list with
  `theta`/`theta_se`, or a numeric measure vector. `se` is required
  (from the fit) to derive the MDC.

- mcid:

  Optional MCID on the logit scale; enables the four-level
  [`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)
  output.

- confidence:

  Confidence level for the MDC (default 0.95).

- direction:

  `"increase"` (default; higher measure = better) or `"decrease"`.

## Value

a `data.frame`, one row per person: `pre`, `post`, `change`,
`improvement` (direction-aware), `sem`, `mdc`, `reliable_change` (from
[`mdcResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/mdcResponder.md))
and, if `mcid` given, `classification` (from
[`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md)).
Attributes `sem`, `mdc`, `mcid` record the values used.

## Details

The two occasions must be on a common metric – calibrate the items once
and anchor them, or co-calibrate – and the persons must align by row.

## See also

[`raschAnalyze()`](https://x-biosignal.github.io/PhysioClinical/reference/raschAnalyze.md),
[`mdcResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/mdcResponder.md),
[`classifyResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/classifyResponder.md),
[`estimateMDC()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMDC.md)

## Examples

``` r
pre  <- list(theta = c(0, 0, 0, 0), theta_se = rep(0.3, 4))
post <- list(theta = c(1.5, 0.1, -1.2, 0.05), theta_se = rep(0.3, 4))
raschResponder(pre, post, mcid = 1.0)
#>   pre  post change improvement sem       mdc reliable_change classification
#> 1   0  1.50   1.50        1.50 0.3 0.8315423        improved true_responder
#> 2   0  0.10   0.10        0.10 0.3 0.8315423          stable  non_responder
#> 3   0 -1.20  -1.20       -1.20 0.3 0.8315423        declined  non_responder
#> 4   0  0.05   0.05        0.05 0.3 0.8315423          stable  non_responder
```
