# Register a normative reference in the versioned registry

Persists a validated
[`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md)
to the registry at `<root>/<id>/<version>.rds`, writing a sibling
governance `manifest.json`. The artifact must pass both object validity
and
[`validateNormativeManifest`](https://x-biosignal.github.io/PhysioClinical/reference/validateNormativeManifest.md).

## Usage

``` r
registerNormative(ref, root = NULL, overwrite = FALSE)
```

## Arguments

- ref:

  A
  [`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md).

- root:

  Registry root directory; defaults to the option
  `PhysioClinical.normative_root` or the package's user data dir.

- overwrite:

  Overwrite an already-registered version (default `FALSE`).

## Value

The written `.rds` path, invisibly.

## See also

[`getNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/getNormative.md),
[`listNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/listNormative.md)

## Examples

``` r
ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
  provenance = list(source = "x"), consent = list(status = "public"),
  license = list(spdx = "CC0-1.0"),
  governance = list(custodian = "lab", access_level = "open"))
registerNormative(ref, root = tempfile("norm"))
```
