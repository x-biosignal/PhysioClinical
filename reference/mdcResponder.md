# Classify change scores against the minimal detectable change (MDC)

A first responder-analysis primitive: a change is a real
improvement/decline only if it exceeds the MDC (measurement noise). Uses
[`PhysioCore::mdc`](https://x-biosignal.github.io/PhysioCore//reference/mdc.html).

## Usage

``` r
mdcResponder(change, sem_value, confidence = 0.95)
```

## Arguments

- change:

  Numeric change score(s) (follow-up minus baseline).

- sem_value:

  The standard error of measurement (see
  [`PhysioCore::sem`](https://x-biosignal.github.io/PhysioCore//reference/sem.html)).

- confidence:

  Confidence level for the MDC (default 0.95).

## Value

Character vector: `"improved"`, `"stable"`, or `"declined"`.

## Examples

``` r
mdcResponder(c(5, 0.5, -6), sem_value = 1.5)
#> [1] "improved" "stable"   "declined"
```
