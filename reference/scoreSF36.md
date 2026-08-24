# Score the SF-36 / RAND-36 Health Survey

Scores the RAND 36-Item Health Survey 1.0: each item's raw response is
recoded to 0-100 (via the instrument's `item_recode` map) and averaged
within its scale, giving the eight subscale scores (0-100, higher =
better health) in the returned `subscales`: physical functioning,
role-physical, role-emotional, energy/fatigue, emotional well-being,
social functioning, pain and general health. The health-transition item
is not part of the eight scales. The norm-based T-scores and the PCS/MCS
component summaries use proprietary population weights and are out of
scope.

## Usage

``` r
scoreSF36(items, ...)
```

## Arguments

- items:

  Named numeric raw responses on the questionnaire's own answer scales
  (`q01`, `q03`..`q36`, omitting the health-transition item `q02`), or
  an unnamed vector in the instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md)
  (e.g. `missing = "prorate"` to score a scale from its completed
  items).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
whose `subscales` hold the eight 0-100 scale scores (the `total` is the
grand mean over all items, not a standard SF-36 score).

## References

Hays RD, Sherbourne CD, Mazel RM (1993). The RAND 36-Item Health Survey
1.0. *Health Econ* 2:217-227.

## See also

[`scoreEQ5D5L()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreEQ5D5L.md),
[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md)

## Examples

``` r
# all best-health responses -> every subscale scores 100
best <- stats::setNames(
  c(1, rep(3, 10), rep(2, 7), 1, 1, 1, 1, 6, 6, 1, 1, 6, 6, 1, 6, 5, 5, 1, 5, 1),
  getInstrument("sf36")@items)
scoreSF36(best)@subscales
#> physical_functioning        role_physical       role_emotional 
#>                  100                  100                  100 
#>       energy_fatigue  emotional_wellbeing   social_functioning 
#>                  100                  100                  100 
#>                 pain       general_health 
#>                  100                  100 
```
