# Score the Medical Research Council (MRC) sum score

Sums manual muscle-test grades (0 = no contraction to 5 = normal power)
for six movements tested bilaterally - shoulder abduction, elbow
flexion, wrist extension, hip flexion, knee extension and ankle
dorsiflexion - to a total of 0-60, higher being stronger. A total below
48 defines ICU-acquired weakness.

## Usage

``` r
scoreMRCSum(items, ...)
```

## Arguments

- items:

  Named numeric grades (e.g. `elbow_flexion_r = 4`,
  `ankle_dorsiflexion_l = 3`) or an unnamed vector in the instrument's
  item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing = "prorate"`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-60), the upper-limb / lower-limb / left / right
subscale sums and the weakness stratum.

## See also

[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
scoreMRCSum(stats::setNames(rep(5, 12), getInstrument("mrc_sum")@items))
#> ClinicalScore [mrc_sum]
#>   total = 60  (no_weakness)
#>   subscales:
#>     upper_limb       30
#>     lower_limb       30
#>     left             30
#>     right            30
#>   items used: 12, missing = error
```
