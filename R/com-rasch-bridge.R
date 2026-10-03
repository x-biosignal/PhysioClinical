# Bridge from a clinical instrument to interval (Rasch) measurement.
#
# Most published analyses of an ordinal ADL/IADL scale do not stop at the raw
# sum -- they Rasch-analyse the item responses to (i) rank the items by the
# ability each demands (the ADL "difficulty hierarchy": stairs and bathing hard,
# feeding easy), (ii) check whether the rating categories work as intended
# (ordered thresholds), (iii) place persons on an equal-interval logit scale so
# change is measured honestly, and (iv) report person/item separation
# reliability and item fit. This file recodes a clinical instrument's responses
# to consecutive Rasch categories and hands them to the domain-neutral
# polytomous engine in PhysioAppKit.

# Map one item's responses to consecutive Rasch categories 0..m. If the
# instrument declares admissible item_values (e.g. the Barthel weights
# 0/5/10/15), those define the ordered categories; otherwise the sorted unique
# observed values are used.
.recode_item <- function(resp, allowed) {
  levs <- if (length(allowed)) sort(unique(as.numeric(allowed)))
          else sort(unique(resp[!is.na(resp)]))
  out <- match(resp, levs) - 1L
  if (any(!is.na(resp) & is.na(out))) {
    stop("response value not among the item's admissible levels", call. = FALSE)
  }
  out
}

#' Recode clinical instrument responses to consecutive Rasch categories
#'
#' Turns a persons x items table of responses on an instrument's native scale
#' (e.g. the weighted Barthel levels 0/5/10/15) into the consecutive integer
#' categories 0..m that a Rasch model expects, using the instrument's declared
#' admissible `item_values` as the category order.
#'
#' @param instrument A [ClinicalInstrument] or an instrument id.
#' @param responses A persons x items matrix or data.frame; columns are matched
#'   to the instrument's items by name, or taken in the instrument's item order
#'   if unnamed.
#' @return An integer matrix of consecutive category codes (0..m per item), with
#'   the instrument's item names as columns.
#' @seealso [raschAnalyze()]
#' @export
#' @examples
#' resp <- rbind(c(10, 5, 5, 10, 10, 10, 10, 15, 15, 10),
#'               c(5, 0, 0, 5, 5, 5, 5, 10, 5, 0))
#' colnames(resp) <- getInstrument("barthel")@items
#' raschRecode("barthel", resp)
raschRecode <- function(instrument, responses) {
  if (is.character(instrument)) instrument <- getInstrument(instrument)
  stopifnot(is(instrument, "ClinicalInstrument"))
  items <- instrument@items
  responses <- as.matrix(responses)
  if (is.null(colnames(responses))) {
    if (ncol(responses) != length(items)) {
      stop("unnamed 'responses' must have one column per instrument item",
           call. = FALSE)
    }
    colnames(responses) <- items
  }
  miss <- setdiff(items, colnames(responses))
  if (length(miss)) {
    stop(sprintf("responses missing column(s) for item(s): %s",
                 paste(miss, collapse = ", ")), call. = FALSE)
  }
  responses <- responses[, items, drop = FALSE]
  storage.mode(responses) <- "double"
  out <- responses
  for (nm in items) {
    out[, nm] <- .recode_item(responses[, nm], instrument@item_values[[nm]])
  }
  storage.mode(out) <- "integer"
  out
}

#' Rasch (interval) analysis of a clinical ADL/IADL instrument
#'
#' Fits a polytomous Rasch model to a cohort's responses on a registered
#' instrument and returns the psychometric summary that published ADL/IADL
#' analyses report: the item difficulty hierarchy, category threshold ordering
#' (with disordered-threshold flags), person and item measures on an interval
#' (logit) scale, item fit (infit/outfit), person/item separation reliability,
#' and the raw-score to interval-measure conversion. The Partial Credit Model is
#' the default (it accommodates the Barthel Index's mixed item lengths); pass
#' `model = "RSM"` for a uniform-format scale.
#'
#' Requires the suggested package \pkg{PhysioAppKit} (the domain-neutral engine).
#'
#' @param instrument A [ClinicalInstrument] or an instrument id (e.g.
#'   `"barthel"`, `"lawton_iadl"`).
#' @param responses A persons x items matrix or data.frame of responses on the
#'   instrument's native scale (see [raschRecode()]).
#' @param model `"PCM"` (default) or `"RSM"`.
#' @param ... Passed to [PhysioAppKit::pcm_measure()].
#' @return The `poly_rasch` fit (see [PhysioAppKit::pcm_measure()]) with an added
#'   class `clin_rasch` and extra fields: `instrument` (id), `item_hierarchy`
#'   (items ordered hardest-to-easiest by calibrated location) and `recoded`
#'   (the category matrix analysed).
#' @seealso [raschRecode()], [scoreBarthel()], [PhysioAppKit::pcm_measure()]
#' @export
#' @examples
#' \donttest{
#' set.seed(1)
#' items <- getInstrument("barthel")@items
#' # a small synthetic cohort of weighted Barthel responses
#' resp <- t(replicate(50, {
#'   ability <- stats::rnorm(1)
#'   vapply(c(2, 1, 1, 2, 2, 2, 2, 3, 3, 2), function(m)
#'     c(0, 5, 10, 15)[min(m, max(0, round(ability + m / 2))) + 1], numeric(1))
#' }))
#' colnames(resp) <- items
#' if (requireNamespace("PhysioAppKit", quietly = TRUE)) {
#'   fit <- raschAnalyze("barthel", resp)
#'   fit$item_hierarchy
#' }
#' }
raschAnalyze <- function(instrument, responses, model = c("PCM", "RSM"), ...) {
  model <- match.arg(model)
  if (!requireNamespace("PhysioAppKit", quietly = TRUE)) {
    stop("raschAnalyze() needs the 'PhysioAppKit' package (the Rasch engine); ",
         "install it to run interval analyses.", call. = FALSE)
  }
  if (is.character(instrument)) instrument <- getInstrument(instrument)
  recoded <- raschRecode(instrument, responses)
  fit <- PhysioAppKit::pcm_measure(recoded, model = model, ...)

  hier <- fit$items[order(-fit$items$location), c("item", "location", "se",
                                                  "infit", "outfit",
                                                  "disordered")]
  rownames(hier) <- NULL
  fit$instrument <- instrument@id
  fit$item_hierarchy <- hier
  fit$recoded <- recoded
  class(fit) <- c("clin_rasch", class(fit))
  fit
}

#' @export
print.clin_rasch <- function(x, ...) {
  cat(sprintf("<clin_rasch> instrument=%s | %s\n", x$instrument,
              paste0("model=", x$model)))
  NextMethod()
  hardest <- x$item_hierarchy$item[1]
  easiest <- x$item_hierarchy$item[nrow(x$item_hierarchy)]
  cat(sprintf("  difficulty hierarchy: hardest=%s ... easiest=%s\n",
              hardest, easiest))
  invisible(x)
}
