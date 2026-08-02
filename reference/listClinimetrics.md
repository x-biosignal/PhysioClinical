# List available clinimetric constants

List available clinimetric constants

## Usage

``` r
listClinimetrics(instrument = NULL)
```

## Arguments

- instrument:

  Optional instrument to filter by (case insensitive).

## Value

A `data.frame` of the stored clinimetric constants.

## See also

[`getClinimetric()`](https://x-biosignal.github.io/PhysioClinical/reference/getClinimetric.md)

## Examples

``` r
listClinimetrics("6MWT")
#>   instrument subscale   population statistic value ci_low ci_high
#> 1       6MWT distance older_adults MCID_dist    20     NA      NA
#> 2       6MWT distance older_adults      MCII    50     NA      NA
#>             method                    reference_doi population_n
#> 1 small_meaningful 10.1111/j.1532-5415.2006.00701.x          492
#> 2      substantial 10.1111/j.1532-5415.2006.00701.x          492
#>                                                      provenance_note
#> 1 Perera 2006; small meaningful change in 6-minute walk distance (m)
#> 2      Perera 2006; substantial change in 6-minute walk distance (m)
```
