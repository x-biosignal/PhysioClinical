# Modified Ashworth Scale level label for a value

The inverse of the MAS arithmetic mapping: returns the ordinal label for
a numeric MAS value (so `1.5` round-trips to `"1+"`).

## Usage

``` r
masLevelLabel(value)
```

## Arguments

- value:

  Numeric MAS value(s).

## Value

Character MAS level label(s).

## See also

[`scoreMAS()`](https://x-biosignal.github.io/PhysioClinical/reference/scoreMAS.md)

## Examples

``` r
masLevelLabel(1.5)
#> [1] "1+"
```
