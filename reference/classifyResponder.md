# Dual MDC-vs-MCID responder classification

Classifies each subject's pre-to-post change with the two-criterion
responder framework (Beaton 2001; de Vet 2006): a change is
cross-tabulated on whether it exceeds the Minimal Detectable Change (is
it real, above measurement error?) and the Minimal Clinically Important
Difference (is it clinically meaningful?), giving four categories —
`true_responder` (exceeds both), `subclinical_change` (real but below
MCID), `measurement_error` (claims MCID but within noise, only when MCID
\< MDC) and `non_responder`. Vectorized over subjects and
direction-aware.

## Usage

``` r
classifyResponder(
  baseline,
  followup,
  instrument = NULL,
  population = NULL,
  mdc = NULL,
  mcid = NULL,
  direction = c("increase", "decrease")
)

# S3 method for class 'responder_classification'
summary(object, ...)
```

## Arguments

- baseline, followup:

  Numeric vectors of pre / post scores (one per subject).

- instrument, population:

  Optional instrument / population used to look up `mdc`/`mcid` from the
  clinimetric store when they are not given.

- mdc, mcid:

  Optional explicit MDC / MCID thresholds (positive); override the store
  lookup.

- direction:

  `"increase"` (default) if higher is better, or `"decrease"` if lower
  is better.

- object:

  A `"responder_classification"`.

- ...:

  Unused.

## Value

A `"responder_classification"` `data.frame` with the change, the
direction-aware improvement, the MDC/MCID crossing flags and the
four-level `classification` factor. A subject with a missing
`baseline`/`followup` gets `NA` flags and classification (missing, not
assumed a non-responder);
[`summary()`](https://rdrr.io/r/base/summary.html) counts it.

`summary` returns the MDC x MCID contingency table.

## References

Beaton DE et al. (2001); de Vet HCW et al. (2006).

## See also

[`estimateMDC()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMDC.md),
[`getClinimetric()`](https://x-biosignal.github.io/PhysioClinical/reference/getClinimetric.md),
[`mdcResponder()`](https://x-biosignal.github.io/PhysioClinical/reference/mdcResponder.md)

## Examples

``` r
classifyResponder(c(20, 25, 30), c(31, 26, 45), mdc = 5.2, mcid = 9)
#> <responder_classification> 3 subject(s), direction: increase
#>   MDC = 5.2, MCID = 9
#> 
#>     true_responder subclinical_change  measurement_error      non_responder 
#>                  2                  0                  0                  1 
```
