# Compare a measured joint ROM to the reference (and the other side)

Compares a measured joint range of motion against the packaged reference
angle (see
[`romReference()`](https://x-biosignal.github.io/PhysioClinical/reference/romReference.md))
and, when supplied, the contralateral (usually unaffected) side - the
two comparisons clinicians read a goniometry measurement against.

## Usage

``` r
romNormalcy(measured, joint, motion, contralateral = NULL)
```

## Arguments

- measured:

  Measured range of motion, in degrees.

- joint, motion:

  The joint and motion (case insensitive); must identify a single
  reference row.

- contralateral:

  Optional measured ROM of the other side, in degrees.

## Value

A one-row `data.frame` (class `"rom_normalcy"`) with `reference_deg`,
`percent_of_normal` (`NA` for an extension-to-neutral motion whose
reference is 0 deg), `deficit_vs_reference` (reference minus measured)
and `limited` (measured below reference); plus `contralateral_deg`,
`deficit_vs_contralateral` and `percent_of_contralateral` when a
contralateral value is given.

## See also

[`romReference()`](https://x-biosignal.github.io/PhysioClinical/reference/romReference.md)

## Examples

``` r
romNormalcy(100, "knee", "flexion")
#> knee flexion (sagittal): 100 deg vs reference 135 deg (74% of normal, deficit 35 deg)  [AAOS/Norkin-White]
romNormalcy(100, "knee", "flexion", contralateral = 130)
#> knee flexion (sagittal): 100 deg vs reference 135 deg (74% of normal, deficit 35 deg); contralateral 130 deg (deficit 30 deg)  [AAOS/Norkin-White]
```
