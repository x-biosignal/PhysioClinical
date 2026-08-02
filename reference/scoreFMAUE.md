# Score the Fugl-Meyer Assessment, Upper Extremity (FMA-UE)

Score the Fugl-Meyer Assessment, Upper Extremity (FMA-UE)

## Usage

``` r
scoreFMAUE(items, ...)
```

## Arguments

- items:

  Named numeric responses (0-2 per item) for the 33 FMA-UE motor items,
  or an unnamed vector in the instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing`, `subject_id`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-66), the four subscale scores (shoulder/elbow/forearm,
wrist, hand, coordination/speed) and the severe/moderate/mild stratum
(Woodbury 2013).

## See also

[`scoreARAT()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreARAT.md),
[`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)

## Examples

``` r
scoreFMAUE(stats::setNames(rep(2, 33), getInstrument("fma_ue")@items))
#> ClinicalScore [fma_ue]
#>   total = 66  (mild)
#>   subscales:
#>     shoulder_elbow_forearm 36
#>     wrist            10
#>     hand             14
#>     coordination_speed 6
#>   items used: 33, missing = error
```
