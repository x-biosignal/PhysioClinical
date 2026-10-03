# Load-once cache of the packaged clinimetric constants table.
.clinimetrics_cache <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      f <- system.file("extdata", "clinimetrics", "mcid_mdc.csv",
                       package = "PhysioClinical")
      if (!nzchar(f)) {
        stop("the packaged clinimetric constants file is missing.",
             call. = FALSE)
      }
      cache <<- utils::read.csv(f, stringsAsFactors = FALSE,
                                encoding = "UTF-8", na.strings = "NA")
    }
    cache
  }
})

#' Look up a per-instrument clinimetric constant
#'
#' Retrieves a published clinimetric statistic (MDC, MCID, MCII, SEM, ICC, ...)
#' for a measurement instrument from the packaged, provenanced constants store.
#' The return value carries the source reference (DOI, population n, provenance
#' note) so a looked-up threshold is always attributable.
#'
#' @param instrument Instrument name (e.g. \code{"FMA-UE"}, \code{"10mWT"}); case
#'   insensitive.
#' @param statistic One of \code{"MDC"}, \code{"MCID_anchor"},
#'   \code{"MCID_dist"}, \code{"MCII"}, \code{"SEM"}, \code{"ICC"} (case
#'   insensitive).
#' @param population Optional population/context key to disambiguate multiple
#'   rows (e.g. \code{"chronic_stroke_minimal"}).
#' @return A \code{"clinimetric"} \code{data.frame} of the matching row(s) with
#'   \code{value}, CI, \code{method}, \code{reference_doi}, \code{population_n}
#'   and \code{provenance_note}; or \code{NA} with a warning when nothing (or no
#'   such population) matches.
#' @seealso [listClinimetrics()]
#' @examples
#' getClinimetric("10mWT", "MCII")
#' getClinimetric("FMA-UE", "MCID_anchor", population = "chronic_stroke_minimal")
#' @export
getClinimetric <- function(instrument, statistic, population = NULL) {
  tbl <- .clinimetrics_cache()
  rows <- tbl[tolower(tbl$instrument) == tolower(instrument) &
                tolower(tbl$statistic) == tolower(statistic), , drop = FALSE]
  if (nrow(rows) == 0L) {
    warning(sprintf("no '%s' clinimetric for instrument '%s'.",
                    statistic, instrument), call. = FALSE)
    return(NA)
  }
  if (!is.null(population)) {
    prows <- rows[tolower(rows$population) == tolower(population), , drop = FALSE]
    if (nrow(prows) == 0L) {
      warning(sprintf(
        "no '%s' for '%s' in population '%s'; available populations: %s.",
        statistic, instrument, population,
        paste(unique(rows$population), collapse = ", ")), call. = FALSE)
      return(NA)
    }
    rows <- prows
  }
  rownames(rows) <- NULL
  class(rows) <- c("clinimetric", "data.frame")
  rows
}

#' List available clinimetric constants
#'
#' @param instrument Optional instrument to filter by (case insensitive).
#' @return A \code{data.frame} of the stored clinimetric constants.
#' @seealso [getClinimetric()]
#' @examples
#' listClinimetrics("6MWT")
#' @export
listClinimetrics <- function(instrument = NULL) {
  tbl <- .clinimetrics_cache()
  if (!is.null(instrument)) {
    tbl <- tbl[tolower(tbl$instrument) == tolower(instrument), , drop = FALSE]
  }
  rownames(tbl) <- NULL
  tbl
}

#' @export
print.clinimetric <- function(x, ...) {
  y <- x
  class(y) <- "data.frame"
  for (i in seq_len(nrow(y))) {
    cat(sprintf("%s %s [%s] = %s  (%s; n=%s, doi:%s)\n",
                y$instrument[i], y$statistic[i], y$population[i],
                format(y$value[i]), y$method[i], format(y$population_n[i]),
                y$reference_doi[i]))
  }
  invisible(x)
}
