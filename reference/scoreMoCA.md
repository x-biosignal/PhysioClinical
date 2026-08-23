# Score the Montreal Cognitive Assessment (MoCA)

Sums the seven MoCA domains (visuospatial/executive, naming, attention,
language, abstraction, delayed recall and orientation) to a total of
0-30. A total below 26 indicates cognitive impairment. One point is
conventionally added for participants with 12 or fewer years of formal
education (total capped at 30); apply that adjustment to the
`orientation` item (or the total) before or after scoring as appropriate
for your protocol.

## Usage

``` r
scoreMoCA(items, ...)
```

## Arguments

- items:

  Named numeric responses giving the points earned on each domain (e.g.
  `delayed_recall = 3`, `orientation = 6`), or an unnamed vector in the
  instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-30) and the impairment stratum (normal / mild /
moderate-severe impairment).

## See also

[`scoreMMSE()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMMSE.md),
[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
scoreMoCA(stats::setNames(c(5, 3, 6, 3, 2, 5, 6),
                          getInstrument("moca")@items))
#> ClinicalScore [moca]
#>   total = 30  (normal)
#>   items used: 7, missing = error
```
