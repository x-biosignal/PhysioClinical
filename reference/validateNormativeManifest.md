# Validate a normative-artifact governance manifest

Checks that a normative reference's manifest carries every required
governance field — a semantic `version`, and non-empty
`provenance$source`, `consent$status`, `license$spdx`,
`governance$custodian` and `governance$access_level` — so an ungoverned
artifact cannot be registered or distributed.

## Usage

``` r
validateNormativeManifest(manifest)
```

## Arguments

- manifest:

  A manifest list, a
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md),
  or a path to a `manifest.json` file.

## Value

`TRUE` invisibly if valid; otherwise an error naming the missing or
invalid fields.

## See also

[`registerNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/registerNormative.md),
[`GovernedNormativeReference()`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference.md)

## Examples

``` r
ref <- GovernedNormativeReference("m", "gait", "gait_speed",
  provenance = list(source = "x"), consent = list(status = "public"),
  license = list(spdx = "CC0-1.0"),
  governance = list(custodian = "lab", access_level = "open"))
validateNormativeManifest(ref)
```
