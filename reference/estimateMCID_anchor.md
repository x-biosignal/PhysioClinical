# Anchor-based MCID

Estimates the MCID from change scores anchored to an external
improvement indicator. `"roc"` returns the change cut-off that maximizes
the Youden index for classifying the anchor; `"mean_change"` the mean
change among the (minimally) improved; `"predictive"` the change at
which a logistic model of the anchor crosses probability 0.5.

## Usage

``` r
estimateMCID_anchor(
  change,
  anchor,
  method = c("roc", "mean_change", "predictive"),
  direction = c("increase", "decrease")
)
```

## Arguments

- change:

  Numeric change scores (follow-up minus baseline).

- anchor:

  Improvement indicator aligned to `change`: logical, or 0/1, where
  TRUE/1 marks an (minimally) improved case.

- method:

  `"roc"` (default), `"mean_change"` or `"predictive"`.

- direction:

  `"increase"` (default) if a higher change means improvement, or
  `"decrease"` if a lower change does.

## Value

The MCID estimate (on the change scale).

## References

Jaeschke et al. (1989); Copay et al. (2007).

## See also

[`estimateMDC()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMDC.md),
[`estimateMCID_distribution()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMCID_distribution.md)

## Examples

``` r
set.seed(1)
change <- c(rnorm(50, 1, 2), rnorm(50, 8, 2))
anchor <- rep(c(0, 1), each = 50)
estimateMCID_anchor(change, anchor)
#> [1] 4.290322
```
