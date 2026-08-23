# Score the Mini-Mental State Examination (MMSE)

Sums the eleven MMSE components (orientation to time and place,
registration, attention/calculation, recall, naming, repetition, a
three-stage command, reading, writing and figure copying) to a total of
0-30, higher being better cognition.

## Usage

``` r
scoreMMSE(items, ...)
```

## Arguments

- items:

  Named numeric responses giving the points earned on each component
  (e.g. `orientation_time = 5`, `recall = 2`), or an unnamed vector in
  the instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing`, `subject_id`).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-30), the six-domain subscale scores and the impairment
stratum (no / mild / severe impairment).

## See also

[`scoreMoCA()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMoCA.md),
[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
scoreMMSE(stats::setNames(c(5, 5, 3, 5, 3, 2, 1, 3, 1, 1, 1),
                          getInstrument("mmse")@items))
#> ClinicalScore [mmse]
#>   total = 30  (no_impairment)
#>   subscales:
#>     orientation      10
#>     registration     3
#>     attention        5
#>     recall           3
#>     language         8
#>     visuoconstruction 1
#>   items used: 11, missing = error
```
