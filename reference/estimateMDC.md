# Distribution-based Minimal Detectable Change from test-retest data

Estimates the MDC from a test-retest reliability study: the intraclass
correlation gives the reliability, the standard error of measurement is
\\SD\sqrt{1 - ICC}\\, and \\MDC = SEM \times z \times \sqrt{2}\\
(delegating to
[`PhysioCore::icc`](https://x-biosignal.r-universe.dev/PhysioCore/reference/icc.html)/`sem`/`mdc`).

## Usage

``` r
estimateMDC(
  test_retest,
  method = "distribution",
  confidence = 0.95,
  model = c("twoway", "oneway")
)
```

## Arguments

- test_retest:

  A subjects-by-occasions numeric matrix (or data.frame) of repeated
  measurements.

- method:

  Estimation method; currently `"distribution"`.

- confidence:

  Confidence level for the MDC (default 0.95).

- model:

  ICC model passed to
  [`PhysioCore::icc`](https://x-biosignal.r-universe.dev/PhysioCore/reference/icc.html)
  (default `"twoway"`).

## Value

A list with `mdc`, `sem`, `icc` and `confidence`.

## References

Shrout & Fleiss (1979); de Vet et al. (2006).

## See also

[`estimateMCID_distribution()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMCID_distribution.md),
[`estimateMCID_anchor()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMCID_anchor.md)

## Examples

``` r
set.seed(1)
base <- rnorm(40, 50, 10)
retest <- base + rnorm(40, 0, 3)
estimateMDC(cbind(base, retest))
#> $mdc
#> [1] 5.389172
#> 
#> $sem
#> [1] 1.944281
#> 
#> $icc
#> [1] 0.9565712
#> 
#> $confidence
#> [1] 0.95
#> 
```
