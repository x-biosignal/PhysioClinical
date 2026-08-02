# Register a clinical instrument

Adds an instrument to the registry, either a
[ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md)
object, a parsed-spec list, or the path to a YAML spec file.

## Usage

``` r
registerInstrument(spec, overwrite = FALSE)
```

## Arguments

- spec:

  A
  [ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md),
  a spec list, or a path to a `.yaml` file.

- overwrite:

  Replace an existing instrument with the same id? Default `FALSE` (an
  existing id is an error).

## Value

Invisibly, the registered
[ClinicalInstrument](https://x-biosignal.github.io/PhysioClinical/reference/ClinicalInstrument.md).

## See also

[`getInstrument()`](https://x-biosignal.github.io/PhysioClinical/reference/getInstrument.md),
[`listInstruments()`](https://x-biosignal.github.io/PhysioClinical/reference/listInstruments.md)

## Examples

``` r
inst <- ClinicalInstrument(id = "toy2", items = c("a", "b"),
  item_ranges = list(a = c(0, 1), b = c(0, 1)))
registerInstrument(inst)
```
