# The governance manifest that gates every registered normative artifact.

# The governance fields every manifest must carry (dotted paths).
.NR_MANIFEST_REQUIRED <- c(
  "version", "provenance.source", "consent.status", "license.spdx",
  "governance.custodian", "governance.access_level")

# Build the plain-list manifest that ships next to an artifact's .rds.
.nr_manifest <- function(ref) {
  list(
    id = ref@id, modality = ref@modality, metric = ref@metric,
    version = ref@version, provenance = ref@provenance,
    consent = ref@consent, license = ref@license,
    governance = ref@governance, strata_vars = as.list(ref@strata_vars),
    n = ref@n)
}

.nr_manifest_ok <- function(manifest, path) {
  parts <- strsplit(path, ".", fixed = TRUE)[[1]]
  if (length(parts) == 1L) {
    return(if (path == "version") .nr_is_semver(manifest$version)
           else .nr_has(manifest, path))
  }
  .nr_has(manifest[[parts[1L]]], parts[2L])
}

#' Validate a normative-artifact governance manifest
#'
#' Checks that a normative reference's manifest carries every required
#' governance field — a semantic \code{version}, and non-empty
#' \code{provenance$source}, \code{consent$status}, \code{license$spdx},
#' \code{governance$custodian} and \code{governance$access_level} — so an
#' ungoverned artifact cannot be registered or distributed.
#'
#' @param manifest A manifest list, a \code{\linkS4class{GovernedNormativeReference}}, or
#'   a path to a \code{manifest.json} file.
#' @return \code{TRUE} invisibly if valid; otherwise an error naming the missing
#'   or invalid fields.
#' @seealso [registerNormative()], [GovernedNormativeReference()]
#' @examples
#' ref <- GovernedNormativeReference("m", "gait", "gait_speed",
#'   provenance = list(source = "x"), consent = list(status = "public"),
#'   license = list(spdx = "CC0-1.0"),
#'   governance = list(custodian = "lab", access_level = "open"))
#' validateNormativeManifest(ref)
#' @importFrom methods is
#' @export
validateNormativeManifest <- function(manifest) {
  if (methods::is(manifest, "GovernedNormativeReference")) {
    manifest <- .nr_manifest(manifest)
  } else if (is.character(manifest) && length(manifest) == 1L &&
             file.exists(manifest)) {
    if (!requireNamespace("jsonlite", quietly = TRUE)) {
      stop("reading a manifest.json requires the 'jsonlite' package.",
           call. = FALSE)
    }
    manifest <- jsonlite::read_json(manifest, simplifyVector = TRUE)
  }
  if (!is.list(manifest)) {
    stop("'manifest' must be a list, a GovernedNormativeReference, or a manifest path.",
         call. = FALSE)
  }
  bad <- .NR_MANIFEST_REQUIRED[
    !vapply(.NR_MANIFEST_REQUIRED,
            function(p) isTRUE(.nr_manifest_ok(manifest, p)), logical(1))]
  if (length(bad)) {
    stop("normative manifest missing/invalid governance field(s): ",
         paste(bad, collapse = ", "), ".", call. = FALSE)
  }
  invisible(TRUE)
}
