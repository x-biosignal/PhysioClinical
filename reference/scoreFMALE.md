# Score the Fugl-Meyer Assessment, Lower Extremity (FMA-LE)

Score the Fugl-Meyer Assessment, Lower Extremity (FMA-LE)

## Usage

``` r
scoreFMALE(items, ...)
```

## Arguments

- items:

  Named numeric responses (0-2 per item) for the 17 FMA-LE motor items,
  or an unnamed vector in the instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-34) and the motor and coordination/speed subscale
scores.

## See also

[`scoreBerg()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreBerg.md),
[`scoreFIM()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreFIM.md)

## Examples

``` r
scoreFMALE(stats::setNames(rep(2, 17), getInstrument("fma_le")@items))
#> ClinicalScore [fma_le]
#>   total = 34
#>   subscales:
#>     motor            28
#>     coordination_speed 6
#>   items used: 17, missing = error
```
