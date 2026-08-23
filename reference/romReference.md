# Joint range-of-motion reference values (goniometry)

Returns the packaged normal active range-of-motion reference values for
the major peripheral joints (shoulder, elbow, forearm, wrist, hip, knee,
ankle). These are the consensus clinical goniometry reference angles (in
degrees) of the American Academy of Orthopaedic Surgeons, as tabulated
by Norkin & White, *Measurement of Joint Motion*. They are single
reference angles (not a distribution), so use
[`romNormalcy()`](https://x-biosignal.github.io/PhysioClinical/reference/romNormalcy.md)
for a reference / side-to-side comparison; for a stratified z-score
build a
[`GovernedNormativeReference()`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference.md)
from a cohort dataset and use
[`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md).

## Usage

``` r
romReference(joint = NULL, motion = NULL)
```

## Arguments

- joint:

  Optional joint to filter by (e.g. `"knee"`; case insensitive).

- motion:

  Optional motion to filter by (e.g. `"flexion"`; case insensitive).

## Value

A `data.frame` with `joint`, `motion`, `plane`, `reference_deg` and
`source`.

## References

American Academy of Orthopaedic Surgeons (1965). *Joint Motion: Method
of Measuring and Recording*. Norkin CC, White DJ. *Measurement of Joint
Motion: A Guide to Goniometry*. F.A. Davis.

## See also

[`romNormalcy()`](https://x-biosignal.github.io/PhysioClinical/reference/romNormalcy.md),
[`normativeZScore()`](https://x-biosignal.github.io/PhysioClinical/reference/normativeZScore.md)

## Examples

``` r
romReference("knee")
#>   joint    motion    plane reference_deg            source
#> 1  knee   flexion sagittal           135 AAOS/Norkin-White
#> 2  knee extension sagittal             0 AAOS/Norkin-White
romReference(motion = "flexion")
#>      joint  motion    plane reference_deg            source
#> 1 shoulder flexion sagittal           180 AAOS/Norkin-White
#> 2    elbow flexion sagittal           150 AAOS/Norkin-White
#> 3    wrist flexion sagittal            80 AAOS/Norkin-White
#> 4      hip flexion sagittal           120 AAOS/Norkin-White
#> 5     knee flexion sagittal           135 AAOS/Norkin-White
```
