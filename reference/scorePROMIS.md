# Score a PROMIS (or other GRM) short form by EAP

Estimates the latent trait for a set of item responses under Samejima's
graded response model by expected a posteriori (EAP) scoring over a
normal quadrature, and reports it on the PROMIS T-score metric (mean 50,
SD 10).

## Usage

``` r
scorePROMIS(
  responses,
  calibration,
  quad_points = 61,
  quad_range = 4,
  prior_mean = 0,
  prior_sd = 1
)
```

## Arguments

- responses:

  Named numeric vector of item responses (category 1..K per item; `NA`
  for a skipped item), or a one-row data.frame. Names must match
  `calibration$item`; an unnamed vector is taken in `calibration` row
  order.

- calibration:

  A data.frame with columns `item`, `a` (slope) and ordered threshold
  columns `b1`, `b2`, ... (a K-category item uses K-1 thresholds; pad
  shorter items with `NA`).

- quad_points, quad_range:

  EAP quadrature: number of nodes and half-width (nodes span
  `[-quad_range, quad_range]`; defaults 61 and 4).

- prior_mean, prior_sd:

  Normal prior on the latent trait (default standard normal, the PROMIS
  calibration metric).

## Value

A list with `theta`, `se_theta`, `tscore` (`50 + 10 * theta`),
`se_tscore` and `n_items` (items actually scored).

## Details

No item parameters are bundled: supply the official PROMIS calibration
(slopes and thresholds) from HealthMeasures. Any GRM-scored instrument
works with the same function.

## References

Samejima F (1969). Estimation of latent ability using a response pattern
of graded scores. *Psychometrika Monograph* 17. PROMIS scoring:
HealthMeasures, www.healthmeasures.net.

## See also

[`promisRawToT()`](https://x-biosignal.github.io/PhysioClinical/reference/promisRawToT.md)

## Examples

``` r
# illustrative calibration (NOT official PROMIS parameters)
cal <- data.frame(item = c("i1", "i2", "i3"), a = c(2.4, 1.9, 2.7),
  b1 = c(-2, -1.5, -1.8), b2 = c(-1, -0.5, -0.7),
  b3 = c(0.2, 0.1, 0), b4 = c(1.4, 1.2, 1.1))
scorePROMIS(c(i1 = 4, i2 = 5, i3 = 4), cal)
#> $theta
#> [1] 0.7861656
#> 
#> $se_theta
#> [1] 0.4244072
#> 
#> $tscore
#> [1] 57.86166
#> 
#> $se_tscore
#> [1] 4.244072
#> 
#> $n_items
#> [1] 3
#> 
```
