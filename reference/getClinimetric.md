# Look up a per-instrument clinimetric constant

Retrieves a published clinimetric statistic (MDC, MCID, MCII, SEM, ICC,
...) for a measurement instrument from the packaged, provenanced
constants store. The return value carries the source reference (DOI,
population n, provenance note) so a looked-up threshold is always
attributable.

## Usage

``` r
getClinimetric(instrument, statistic, population = NULL)
```

## Arguments

- instrument:

  Instrument name (e.g. `"FMA-UE"`, `"10mWT"`); case insensitive.

- statistic:

  One of `"MDC"`, `"MCID_anchor"`, `"MCID_dist"`, `"MCII"`, `"SEM"`,
  `"ICC"` (case insensitive).

- population:

  Optional population/context key to disambiguate multiple rows (e.g.
  `"chronic_stroke_minimal"`).

## Value

A `"clinimetric"` `data.frame` of the matching row(s) with `value`, CI,
`method`, `reference_doi`, `population_n` and `provenance_note`; or `NA`
with a warning when nothing (or no such population) matches.

## See also

[`listClinimetrics()`](https://x-biosignal.github.io/PhysioClinical/reference/listClinimetrics.md)

## Examples

``` r
getClinimetric("10mWT", "MCII")
#> 10mWT MCII [older_adults] = 0.1  (substantial; n=492, doi:10.1111/j.1532-5415.2006.00701.x)
getClinimetric("FMA-UE", "MCID_anchor", population = "chronic_stroke_minimal")
#> FMA-UE MCID_anchor [chronic_stroke_minimal] = 4.25  (roc_anchor; n=74, doi:10.2522/ptj.20110009)
```
