#' Show a normative reference (surfacing its governance)
#'
#' @param object A \code{\linkS4class{GovernedNormativeReference}}.
#' @return \code{object}, invisibly.
#' @importFrom methods show
#' @exportMethod show
setMethod("show", "GovernedNormativeReference", function(object) {
  cat(sprintf("<GovernedNormativeReference> %s  v%s\n", object@id, object@version))
  cat(sprintf("  modality/metric: %s / %s\n", object@modality, object@metric))
  cat(sprintf("  n = %s   strata: %s\n", format(object@n),
              if (length(object@strata_vars))
                paste(object@strata_vars, collapse = ", ") else "-"))
  cat(sprintf("  provenance: %s%s\n", .nr_get(object@provenance, "source"),
              if (.nr_has(object@provenance, "doi"))
                sprintf(" (doi:%s)", .nr_get(object@provenance, "doi")) else ""))
  cat(sprintf("  consent:    %s   ethics: %s\n",
              .nr_get(object@consent, "status"),
              .nr_get(object@consent, "ethics_id")))
  cat(sprintf("  license:    %s   redistribute: %s\n",
              .nr_get(object@license, "spdx"),
              .nr_get(object@license, "redistribution_ok")))
  cat(sprintf("  governance: %s   access: %s\n",
              .nr_get(object@governance, "custodian"),
              .nr_get(object@governance, "access_level")))
  invisible(object)
})
