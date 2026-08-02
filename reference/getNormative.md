# Retrieve a normative reference from the registry

Retrieve a normative reference from the registry

## Usage

``` r
getNormative(id, version = "latest", root = NULL)
```

## Arguments

- id:

  Artifact identifier.

- version:

  Semantic version, or `"latest"` (default) for the highest registered
  version.

- root:

  Registry root (see
  [`registerNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/registerNormative.md)).

## Value

The stored
[`GovernedNormativeReference`](https://x-biosignal.github.io/PhysioClinical/reference/GovernedNormativeReference-class.md).

## See also

[`registerNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/registerNormative.md),
[`listNormative()`](https://x-biosignal.github.io/PhysioClinical/reference/listNormative.md)
