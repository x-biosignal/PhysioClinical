# Versioned, on-disk registry for governed normative artifacts. Each artifact is
# stored under <root>/<id>/<version>.rds with a sibling <version>.manifest.json.

.nr_root <- function(root = NULL) {
  if (!is.null(root)) return(root)
  getOption("PhysioClinical.normative_root",
            file.path(tools::R_user_dir("PhysioClinical", "data"), "normative"))
}

.nr_versions <- function(dir) {
  files <- list.files(dir, pattern = "\\.rds$")
  sub("\\.rds$", "", files)
}

.nr_latest <- function(vers) {
  vers <- vers[.nr_is_semver_v(vers)]
  if (!length(vers)) stop("no semver versions available.", call. = FALSE)
  vers[order(numeric_version(vers))][length(vers)]
}

.nr_is_semver_v <- function(v) grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", v)

#' Register a normative reference in the versioned registry
#'
#' Persists a validated \code{\linkS4class{GovernedNormativeReference}} to the registry
#' at \code{<root>/<id>/<version>.rds}, writing a sibling governance
#' \code{manifest.json}. The artifact must pass both object validity and
#' \code{\link{validateNormativeManifest}}.
#'
#' @param ref A \code{\linkS4class{GovernedNormativeReference}}.
#' @param root Registry root directory; defaults to the option
#'   \code{PhysioClinical.normative_root} or the package's user data dir.
#' @param overwrite Overwrite an already-registered version (default
#'   \code{FALSE}).
#' @return The written \code{.rds} path, invisibly.
#' @seealso [getNormative()], [listNormative()]
#' @examples
#' ref <- GovernedNormativeReference("gs", "gait", "gait_speed",
#'   provenance = list(source = "x"), consent = list(status = "public"),
#'   license = list(spdx = "CC0-1.0"),
#'   governance = list(custodian = "lab", access_level = "open"))
#' registerNormative(ref, root = tempfile("norm"))
#' @importFrom methods is validObject
#' @export
registerNormative <- function(ref, root = NULL, overwrite = FALSE) {
  if (!methods::is(ref, "GovernedNormativeReference")) {
    stop("'ref' must be a GovernedNormativeReference.", call. = FALSE)
  }
  methods::validObject(ref)
  validateNormativeManifest(ref)
  dir <- file.path(.nr_root(root), ref@id)
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  rds <- file.path(dir, paste0(ref@version, ".rds"))
  if (file.exists(rds) && !overwrite) {
    stop(sprintf("version '%s' of '%s' is already registered; ",
                 ref@version, ref@id),
         "pass overwrite = TRUE to replace it.", call. = FALSE)
  }
  saveRDS(ref, rds)
  if (requireNamespace("jsonlite", quietly = TRUE)) {
    jsonlite::write_json(
      .nr_manifest(ref), file.path(dir, paste0(ref@version, ".manifest.json")),
      auto_unbox = TRUE, pretty = TRUE, null = "null")
  }
  invisible(rds)
}

#' Retrieve a normative reference from the registry
#'
#' @param id Artifact identifier.
#' @param version Semantic version, or \code{"latest"} (default) for the highest
#'   registered version.
#' @param root Registry root (see [registerNormative()]).
#' @return The stored \code{\linkS4class{GovernedNormativeReference}}.
#' @seealso [registerNormative()], [listNormative()]
#' @export
getNormative <- function(id, version = "latest", root = NULL) {
  # the read path must enforce the same slug/semver constraints the write path
  # trusts, so a crafted id/version cannot traverse out of the registry root
  # and readRDS an arbitrary (ungoverned) file
  if (!.nr_is_slug(id)) {
    stop("'id' must be a filename-safe slug.", call. = FALSE)
  }
  if (!identical(version, "latest") && !.nr_is_semver_v(version)) {
    stop("'version' must be \"latest\" or a semver 'x.y.z'.", call. = FALSE)
  }
  dir <- file.path(.nr_root(root), id)
  vers <- .nr_versions(dir)
  if (!length(vers)) {
    stop("no registered normative reference '", id, "'.", call. = FALSE)
  }
  v <- if (identical(version, "latest")) .nr_latest(vers) else version
  if (!.nr_is_semver_v(v)) {
    stop("invalid version '", v, "'.", call. = FALSE)
  }
  rds <- file.path(dir, paste0(v, ".rds"))
  if (!file.exists(rds)) {
    stop("version '", v, "' not found for '", id, "'.", call. = FALSE)
  }
  # re-validate on read: the registry must only serve governed artifacts, even
  # if a .rds was corrupted or written out of band
  ref <- readRDS(rds)
  methods::validObject(ref)
  ref
}

#' List registered normative references
#'
#' @param root Registry root (see [registerNormative()]).
#' @return A \code{data.frame} of \code{id}, \code{version}, \code{modality},
#'   \code{metric}, \code{access_level} and \code{n}, newest version last.
#' @seealso [registerNormative()], [getNormative()]
#' @export
listNormative <- function(root = NULL) {
  root <- .nr_root(root)
  empty <- data.frame(id = character(0), version = character(0),
                      modality = character(0), metric = character(0),
                      access_level = character(0), n = numeric(0),
                      stringsAsFactors = FALSE)
  if (!dir.exists(root)) return(empty)
  ids <- list.dirs(root, recursive = FALSE, full.names = FALSE)
  rows <- lapply(ids, function(id) {
    dir <- file.path(root, id)
    vers <- .nr_versions(dir)
    vers <- vers[.nr_is_semver_v(vers)]
    if (!length(vers)) return(NULL)
    vers <- vers[order(numeric_version(vers))]
    do.call(rbind, lapply(vers, function(v) {
      ref <- readRDS(file.path(dir, paste0(v, ".rds")))
      data.frame(id = id, version = v, modality = ref@modality,
                 metric = ref@metric,
                 access_level = .nr_get(ref@governance, "access_level"),
                 n = ref@n, stringsAsFactors = FALSE)
    }))
  })
  rows <- rows[!vapply(rows, is.null, logical(1))]
  if (!length(rows)) return(empty)
  do.call(rbind, rows)
}
