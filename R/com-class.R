# S4 data model for clinical outcome-measure instruments and their scored
# results. A ClinicalInstrument is a data-driven specification (loaded from a
# YAML file, see com-registry.R) and a ClinicalScore is the result of applying
# it to a set of item responses (see com-score.R).

#' Clinical instrument specification
#'
#' A declarative specification of a clinical outcome measure: its items, their
#' admissible ranges and measurement level, its subscales, how items aggregate
#' into scores, the direction of clinical benefit, and the interpretation
#' strata.
#'
#' @slot id Short unique identifier (e.g. `"berg"`).
#' @slot name Human-readable name.
#' @slot version Specification version string.
#' @slot items Character vector of item identifiers, in order.
#' @slot item_ranges Named list; each entry a length-2 numeric `c(min, max)` for
#'   the corresponding item.
#' @slot item_type Character vector (recycled to the item count) of `"interval"`
#'   or `"ordinal"`.
#' @slot subscales Named list mapping each subscale name to a character vector of
#'   its item identifiers; length 0 for single-scale instruments.
#' @slot aggregation `"sum"` or `"mean"`.
#' @slot direction `"higher_better"` or `"higher_worse"`.
#' @slot strata List of interpretation bands, each a list with `label`, `lower`
#'   and `upper`.
#' @slot item_values Optional named list; for an item with a discrete (possibly
#'   non-integer) admissible value set - e.g. the Modified Ashworth `1+` = 1.5 -
#'   the numeric vector of allowed values. Items absent from the list are
#'   validated only against `item_ranges` / `item_type`.
#' @slot item_recode Optional named list; for an item whose raw responses are
#'   recoded before scoring (e.g. the SF-36 0-100 recode, or a reversed item), a
#'   named numeric map from the raw response (a character key) to the scored
#'   value. Applied after validation, before aggregation.
#' @slot source_ref Citation / provenance string.
#' @exportClass ClinicalInstrument
setClass(
  "ClinicalInstrument",
  representation(
    id = "character", name = "character", version = "character",
    items = "character", item_ranges = "list", item_type = "character",
    subscales = "list", aggregation = "character", direction = "character",
    strata = "list", item_values = "list", item_recode = "list",
    source_ref = "character"
  ),
  prototype(
    id = NA_character_, name = NA_character_, version = NA_character_,
    items = character(0), item_ranges = list(), item_type = "interval",
    subscales = list(), aggregation = "sum", direction = "higher_better",
    strata = list(), item_values = list(), item_recode = list(),
    source_ref = NA_character_
  ),
  validity = function(object) {
    if (length(object@items) < 1L) return("'items' must be non-empty")
    if (anyDuplicated(object@items)) return("'items' must be unique")
    if (!object@aggregation %in% c("sum", "mean")) {
      return("'aggregation' must be 'sum' or 'mean'")
    }
    if (!object@direction %in% c("higher_better", "higher_worse")) {
      return("'direction' must be 'higher_better' or 'higher_worse'")
    }
    if (!all(object@item_type %in% c("interval", "ordinal"))) {
      return("'item_type' entries must be 'interval' or 'ordinal'")
    }
    if (length(object@item_type) != length(object@items)) {
      return("'item_type' must have one entry per item")
    }
    if (!all(object@items %in% names(object@item_ranges))) {
      return("every item needs an entry in 'item_ranges'")
    }
    if (!all(vapply(object@item_ranges, function(r)
      is.numeric(r) && length(r) == 2L && r[1] <= r[2], logical(1)))) {
      return("each 'item_ranges' entry must be numeric c(min, max) with min <= max")
    }
    for (nm in names(object@subscales)) {
      if (!all(object@subscales[[nm]] %in% object@items)) {
        return(sprintf("subscale '%s' references unknown items", nm))
      }
    }
    for (s in object@strata) {
      if (!all(c("label", "lower", "upper") %in% names(s))) {
        return("each stratum needs 'label', 'lower' and 'upper'")
      }
      if (!(is.numeric(s$lower) && is.numeric(s$upper) && s$lower <= s$upper)) {
        return("each stratum needs numeric lower <= upper")
      }
    }
    if (length(object@item_values)) {
      if (!all(names(object@item_values) %in% object@items)) {
        return("'item_values' names must be items of the instrument")
      }
      if (!all(vapply(object@item_values, is.numeric, logical(1)))) {
        return("each 'item_values' entry must be a numeric vector")
      }
    }
    if (length(object@item_recode)) {
      if (!all(names(object@item_recode) %in% object@items)) {
        return("'item_recode' names must be items of the instrument")
      }
      if (!all(vapply(object@item_recode, function(m)
        is.numeric(m) && !is.null(names(m)), logical(1)))) {
        return("each 'item_recode' entry must be a named numeric map")
      }
    }
    TRUE
  }
)

#' Construct a ClinicalInstrument
#'
#' @param id,name,version,items,item_ranges,item_type,subscales,aggregation,direction,strata,item_values,item_recode,source_ref
#'   Instrument specification fields (see the class slots).
#' @return A `ClinicalInstrument`.
#' @seealso [scoreInstrument()], [registerInstrument()]
#' @importFrom methods is new validObject
#' @export
#' @examples
#' ClinicalInstrument(
#'   id = "toy", name = "Toy scale", items = c("q1", "q2"),
#'   item_ranges = list(q1 = c(0, 4), q2 = c(0, 4)))
ClinicalInstrument <- function(id, name = NA_character_, version = NA_character_,
                               items, item_ranges, item_type = "interval",
                               subscales = list(), aggregation = "sum",
                               direction = "higher_better", strata = list(),
                               item_values = list(), item_recode = list(),
                               source_ref = NA_character_) {
  it <- if (length(item_type) == 1L) {
    rep(item_type, length(items))
  } else if (!is.null(names(item_type))) {
    # a named item_type maps to items by name, not position
    as.character(item_type[items])
  } else {
    item_type
  }
  new("ClinicalInstrument", id = as.character(id), name = as.character(name),
      version = as.character(version), items = as.character(items),
      item_ranges = item_ranges, item_type = as.character(it),
      subscales = subscales, aggregation = as.character(aggregation),
      direction = as.character(direction), strata = strata,
      item_values = item_values, item_recode = item_recode,
      source_ref = as.character(source_ref))
}

#' Clinical score result
#'
#' The result of scoring a set of item responses against a
#' [ClinicalInstrument].
#'
#' @slot instrument_id Identifier of the scoring instrument.
#' @slot total Total score (or `NA` if unresolved under the missing policy).
#' @slot subscales Named numeric vector of subscale scores.
#' @slot stratum Interpretation stratum label the total falls in (or `NA`).
#' @slot items_used Character vector of the item identifiers actually scored.
#' @slot missing_handling The missing-data policy applied.
#' @slot timestamp Optional character timestamp.
#' @slot subject_id Optional subject identifier.
#' @aliases ClinicalScore
#' @exportClass ClinicalScore
setClass(
  "ClinicalScore",
  representation(
    instrument_id = "character", total = "numeric", subscales = "numeric",
    stratum = "character", items_used = "character",
    missing_handling = "character", timestamp = "character",
    subject_id = "character"
  ),
  prototype(
    instrument_id = NA_character_, total = NA_real_, subscales = numeric(0),
    stratum = NA_character_, items_used = character(0),
    missing_handling = NA_character_, timestamp = NA_character_,
    subject_id = NA_character_
  ),
  validity = function(object) {
    if (length(object@total) != 1L) return("'total' must be a scalar")
    if (length(object@stratum) != 1L) return("'stratum' must be a scalar")
    if (length(object@subscales) &&
        is.null(names(object@subscales))) {
      return("'subscales' must be a named numeric vector")
    }
    TRUE
  }
)
