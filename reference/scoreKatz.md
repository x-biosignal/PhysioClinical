# Score the Katz Index of Independence in ADL

Six basic ADL activities (bathing, dressing, toileting, transferring,
continence, feeding), each scored independent (1) or dependent (0), for
a total of 0-6.

## Usage

``` r
scoreKatz(items, ...)
```

## Arguments

- items:

  Named numeric responses (0/1 per activity) or an unnamed vector in the
  instrument's item order.

- ...:

  Passed to
  [`scoreInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreInstrument.md).

## Value

A
[ClinicalScore](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalScore-class.md)
with the total (0-6) and the impairment stratum.

## See also

[`scoreBarthel()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreBarthel.md),
[`scoreLawton()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreLawton.md)

## Examples

``` r
scoreKatz(c(bathing = 1, dressing = 1, toileting = 1,
            transferring = 1, continence = 0, feeding = 1))
#> ClinicalScore [katz_adl]
#>   total = 5  (independent)
#>   items used: 6, missing = error
```
