# Shared helpers for the normative-reference governance model.

# TRUE when a governance list carries a usable value for `field` — a non-NA,
# non-blank scalar (whitespace-only and NA are treated as absent so they cannot
# slip a governance field past the gate).
.nr_has <- function(lst, field) {
  if (!is.list(lst)) return(FALSE)
  v <- lst[[field]]
  if (is.null(v) || length(v) == 0L) return(FALSE)
  # test missingness on the raw value: is.na(NaN) is TRUE, but as.character(NaN)
  # is the non-NA string "NaN", so a numeric NA-sentinel would otherwise slip in
  if (isTRUE(is.na(v[[1L]]))) return(FALSE)
  v1 <- as.character(v)[1L]
  !is.na(v1) && nzchar(trimws(v1))
}

# A safe registry slug (no path separators / traversal).
.nr_is_slug <- function(x) {
  length(x) == 1L && !is.na(x) && grepl("^[A-Za-z0-9._-]+$", x) &&
    !grepl("^\\.+$", x)
}

# A printable scalar for a governance field (or "NA" when absent).
.nr_get <- function(lst, field) {
  if (.nr_has(lst, field)) as.character(lst[[field]])[1L] else "NA"
}

.nr_is_semver <- function(v) {
  is.character(v) && length(v) == 1L && grepl("^[0-9]+\\.[0-9]+\\.[0-9]+$", v)
}

#' Governed normative reference
#'
#' An S4 container for a normative reference distribution together with the
#' governance metadata a clinical artifact must carry: provenance, consent,
#' license and custodianship. Validity requires the provenance source, consent
#' status and license identifier to be present, so an ungoverned reference
#' cannot be constructed.
#'
#' @slot id Stable artifact identifier.
#' @slot modality Signal modality (e.g. \code{"gait"}, \code{"hrv"}).
#' @slot metric The normed quantity (e.g. \code{"gait_speed"}).
#' @slot version Semantic version string \code{"x.y.z"}.
#' @slot provenance List with at least \code{source}; optionally \code{doi},
#'   \code{collection_date}.
#' @slot consent List with at least \code{status}; optionally \code{ethics_id}.
#' @slot license List with at least \code{spdx}; optionally
#'   \code{redistribution_ok}.
#' @slot governance List with \code{custodian} and \code{access_level}.
#' @slot strata_vars Character vector of stratification variables (e.g.
#'   \code{c("age", "sex")}).
#' @slot model List holding the normative model — either a stratified
#'   mean/sd table or LMS (\code{lambda}/\code{mu}/\code{sigma}) coefficients.
#' @slot n Reference sample size.
#' @name GovernedNormativeReference-class
#' @rdname GovernedNormativeReference-class
#' @exportClass GovernedNormativeReference
setClass(
  "GovernedNormativeReference",
  slots = c(
    id = "character", modality = "character", metric = "character",
    version = "character", provenance = "list", consent = "list",
    license = "list", governance = "list", strata_vars = "character",
    model = "list", n = "numeric"
  ),
  prototype = list(
    id = NA_character_, modality = NA_character_, metric = NA_character_,
    version = "1.0.0", provenance = list(), consent = list(),
    license = list(), governance = list(), strata_vars = character(0),
    model = list(), n = NA_real_
  )
)

setValidity("GovernedNormativeReference", function(object) {
  errs <- character()
  if (length(object@id) != 1L || is.na(object@id) || !nzchar(object@id)) {
    errs <- c(errs, "'id' must be a non-empty string")
  } else if (!.nr_is_slug(object@id)) {
    errs <- c(errs, paste0("'id' must be a filename-safe slug ",
                           "([A-Za-z0-9._-], no path separators)"))
  }
  for (s in c("modality", "metric")) {
    v <- slot(object, s)
    if (length(v) != 1L || is.na(v) || !nzchar(v)) {
      errs <- c(errs, sprintf("'%s' must be a non-empty string", s))
    }
  }
  if (!.nr_is_semver(object@version)) {
    errs <- c(errs, "'version' must be a semver string 'x.y.z'")
  }
  # governance gate: provenance + consent + license must be present
  if (!.nr_has(object@provenance, "source")) {
    errs <- c(errs, "provenance$source is required")
  }
  if (!.nr_has(object@consent, "status")) {
    errs <- c(errs, "consent$status is required")
  }
  if (!.nr_has(object@license, "spdx")) {
    errs <- c(errs, "license$spdx is required")
  }
  if (length(errs)) errs else TRUE
})

#' Construct a governed normative reference
#'
#' @param id,modality,metric Identifying strings.
#' @param version Semantic version (default \code{"1.0.0"}).
#' @param provenance,consent,license,governance Governance lists (see
#'   \code{\linkS4class{GovernedNormativeReference}}); \code{provenance$source},
#'   \code{consent$status} and \code{license$spdx} are required.
#' @param strata_vars Character vector of stratification variables.
#' @param model List holding the normative model (stratified mean/sd table or
#'   LMS coefficients).
#' @param n Reference sample size.
#' @return A validated \code{\linkS4class{GovernedNormativeReference}}.
#' @seealso [registerNormative()], [validateNormativeManifest()]
#' @examples
#' GovernedNormativeReference(
#'   id = "gait_speed_adult", modality = "gait", metric = "gait_speed",
#'   version = "1.0.0",
#'   provenance = list(source = "Bohannon 1997", doi = "10.1093/ageing/26.1.15"),
#'   consent = list(status = "public_aggregate"),
#'   license = list(spdx = "CC-BY-4.0", redistribution_ok = TRUE),
#'   governance = list(custodian = "Matsui Lab", access_level = "open"),
#'   strata_vars = c("age", "sex"),
#'   model = list(type = "strata",
#'                table = data.frame(age = 70, sex = "M", mean = 1.3, sd = 0.2)),
#'   n = 230)
#' @importFrom methods new validObject is slot
#' @export
GovernedNormativeReference <- function(id, modality, metric, version = "1.0.0",
                               provenance = list(), consent = list(),
                               license = list(), governance = list(),
                               strata_vars = character(0), model = list(),
                               n = NA_real_) {
  methods::new("GovernedNormativeReference",
      id = as.character(id), modality = as.character(modality),
      metric = as.character(metric), version = as.character(version),
      provenance = as.list(provenance), consent = as.list(consent),
      license = as.list(license), governance = as.list(governance),
      strata_vars = as.character(strata_vars), model = as.list(model),
      n = as.numeric(n))
}
