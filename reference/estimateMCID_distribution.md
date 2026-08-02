# Distribution-based MCID (fraction-of-SD rule)

The distribution-based Minimal Clinically Important Difference as a
fraction of the baseline standard deviation (Norman et al. 2003: the 0.5
SD rule).

## Usage

``` r
estimateMCID_distribution(baseline_sd, fraction = 0.5)
```

## Arguments

- baseline_sd:

  Baseline standard deviation of the outcome.

- fraction:

  Fraction of the SD (default 0.5).

## Value

The MCID estimate (`fraction * baseline_sd`).

## References

Norman GR, Sloan JA, Wyrwich KW (2003). *Med Care* 41(5).

## See also

[`estimateMDC()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMDC.md),
[`estimateMCID_anchor()`](https://x-biosignal.github.io/PhysioClinical/reference/estimateMCID_anchor.md)

## Examples

``` r
estimateMCID_distribution(baseline_sd = 12)
#> [1] 6
```
