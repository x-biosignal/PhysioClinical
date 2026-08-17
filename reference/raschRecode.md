# Recode clinical instrument responses to consecutive Rasch categories

Turns a persons x items table of responses on an instrument's native
scale (e.g. the weighted Barthel levels 0/5/10/15) into the consecutive
integer categories 0..m that a Rasch model expects, using the
instrument's declared admissible `item_values` as the category order.

## Usage

``` r
raschRecode(instrument, responses)
```

## Arguments

- instrument:

  A
  [ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md)
  or an instrument id.

- responses:

  A persons x items matrix or data.frame; columns are matched to the
  instrument's items by name, or taken in the instrument's item order if
  unnamed.

## Value

An integer matrix of consecutive category codes (0..m per item), with
the instrument's item names as columns.

## See also

[`raschAnalyze()`](https://x-biosignal.github.io/PhysioClinical/reference/raschAnalyze.md)

## Examples

``` r
resp <- rbind(c(10, 5, 5, 10, 10, 10, 10, 15, 15, 10),
              c(5, 0, 0, 5, 5, 5, 5, 10, 5, 0))
colnames(resp) <- getInstrument("barthel")@items
raschRecode("barthel", resp)
#>      feeding bathing grooming dressing bowels bladder toilet_use transfers
#> [1,]       2       1        1        2      2       2          2         3
#> [2,]       1       0        0        1      1       1          1         2
#>      mobility stairs
#> [1,]        3      2
#> [2,]        1      0
```
