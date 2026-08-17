# Display methods for the clinical instrument and score classes.

#' @rdname ClinicalInstrument-class
#' @param object A `ClinicalInstrument`.
#' @export
setMethod("show", "ClinicalInstrument", function(object) {
  cat(sprintf("ClinicalInstrument '%s'%s\n", object@id,
              if (!is.na(object@name)) paste0(": ", object@name) else ""))
  cat(sprintf("  %d items (%s), aggregation = %s, direction = %s\n",
              length(object@items),
              paste(unique(object@item_type), collapse = "/"),
              object@aggregation, object@direction))
  if (length(object@subscales)) {
    cat(sprintf("  subscales: %s\n", paste(names(object@subscales),
                                           collapse = ", ")))
  }
  if (length(object@strata)) {
    labs <- vapply(object@strata, function(s)
      sprintf("%s [%g, %g]", s$label, s$lower, s$upper), character(1))
    cat(sprintf("  strata: %s\n", paste(labs, collapse = "; ")))
  }
  invisible(object)
})

#' @rdname ClinicalScore-class
#' @param object A `ClinicalScore`.
#' @export
setMethod("show", "ClinicalScore", function(object) {
  cat(sprintf("ClinicalScore [%s]%s\n", object@instrument_id,
              if (!is.na(object@subject_id))
                paste0(" subject ", object@subject_id) else ""))
  cat(sprintf("  total = %s%s\n",
              format(object@total),
              if (!is.na(object@stratum)) paste0("  (", object@stratum, ")")
              else ""))
  if (length(object@subscales)) {
    cat("  subscales:\n")
    for (nm in names(object@subscales)) {
      cat(sprintf("    %-16s %s\n", nm, format(object@subscales[[nm]])))
    }
  }
  cat(sprintf("  items used: %d, missing = %s\n",
              length(object@items_used), object@missing_handling))
  invisible(object)
})

#' Convert a ClinicalScore to a one-row data.frame
#'
#' @param x A [ClinicalScore].
#' @param ... Ignored.
#' @param stringsAsFactors Ignored (kept for the S3 generic signature).
#' @return A one-row data.frame with the total, each subscale, the stratum and
#'   the metadata columns.
#' @exportS3Method base::as.data.frame
as.data.frame.ClinicalScore <- function(x, ..., stringsAsFactors = FALSE) {
  base <- data.frame(
    instrument_id = x@instrument_id, subject_id = x@subject_id,
    total = x@total, stratum = x@stratum,
    n_items = length(x@items_used), missing_handling = x@missing_handling,
    timestamp = x@timestamp, stringsAsFactors = FALSE)
  if (length(x@subscales)) {
    sub <- as.data.frame(as.list(x@subscales), stringsAsFactors = FALSE)
    names(sub) <- paste0("subscale_", names(x@subscales))
    base <- cbind(base, sub)
  }
  base
}
