# Data-driven scoring of item responses against a ClinicalInstrument.

# Aggregate a set of item values (already validated, missing dropped) by the
# instrument's rule.
.aggregate <- function(values, aggregation) {
  if (aggregation == "mean") mean(values) else sum(values)
}

# Recode raw item responses to their scored values when the instrument declares
# an item_recode map (e.g. the SF-36 0-100 recode, or a reversed item). Applied
# after validation and before aggregation; a missing (NA) response stays missing.
.apply_recode <- function(instrument, vals) {
  rc <- instrument@item_recode
  if (!length(rc)) return(vals)
  for (nm in names(rc)) {
    v <- vals[[nm]]
    if (is.null(v) || is.na(v)) next
    map <- rc[[nm]]
    key <- as.character(v)
    if (!key %in% names(map)) {
      stop(sprintf("Item '%s' response %s has no recode entry (allowed: %s).",
                   nm, key, paste(names(map), collapse = ", ")), call. = FALSE)
    }
    vals[[nm]] <- unname(map[[key]])
  }
  vals
}

# Coerce a response to numeric, reading a factor by its labels (not its integer
# codes) and erroring informatively on genuinely non-numeric input.
.clin_numeric <- function(x) {
  if (is.factor(x)) x <- as.character(x)
  out <- suppressWarnings(as.numeric(x))
  if (length(out) && any(is.na(out) & !is.na(x))) {
    stop("Item responses must be numeric (or numeric-coercible).", call. = FALSE)
  }
  out
}

# Validate item responses against the instrument's ranges and measurement level.
# Returns the numeric response vector aligned to the instrument's item order.
validateItems <- function(instrument, items) {
  stopifnot(is(instrument, "ClinicalInstrument"))
  if (is.data.frame(items)) {
    items <- stats::setNames(.clin_numeric(unlist(items[1, ])), names(items))
  } else {
    items <- stats::setNames(.clin_numeric(items), names(items))
  }
  if (is.null(names(items))) {
    if (length(items) != length(instrument@items)) {
      stop("Unnamed 'items' must have one value per instrument item, in order.",
           call. = FALSE)
    }
    names(items) <- instrument@items
  }
  dup <- unique(names(items)[duplicated(names(items))])
  if (length(dup)) {
    stop(sprintf("Duplicated item name(s) in 'items': %s",
                 paste(dup, collapse = ", ")), call. = FALSE)
  }
  extra <- setdiff(names(items), instrument@items)
  if (length(extra)) {
    stop(sprintf("Unknown item(s) for instrument '%s': %s",
                 instrument@id, paste(extra, collapse = ", ")), call. = FALSE)
  }
  vals <- stats::setNames(rep(NA_real_, length(instrument@items)),
                          instrument@items)
  vals[names(items)] <- as.numeric(items)

  it_type <- stats::setNames(instrument@item_type, instrument@items)
  for (nm in instrument@items) {
    v <- vals[[nm]]
    if (is.na(v)) next
    rng <- instrument@item_ranges[[nm]]
    if (v < rng[1] || v > rng[2]) {
      stop(sprintf("Item '%s' value %g is outside its range [%g, %g].",
                   nm, v, rng[1], rng[2]), call. = FALSE)
    }
    if (it_type[[nm]] == "ordinal" && v != round(v)) {
      stop(sprintf("Ordinal item '%s' must be an integer, got %g.", nm, v),
           call. = FALSE)
    }
    allowed <- instrument@item_values[[nm]]
    if (!is.null(allowed) && !any(abs(allowed - v) < 1e-9)) {
      stop(sprintf("Item '%s' value %g is not an allowed level (%s).",
                   nm, v, paste(allowed, collapse = ", ")), call. = FALSE)
    }
  }
  vals
}

# Aggregate the items of one subscale (or the whole instrument), applying the
# missing-data policy. Returns the score (possibly NA) and the items used.
.score_set <- function(vals, item_ids, aggregation, missing) {
  v <- vals[item_ids]
  observed <- item_ids[!is.na(v)]
  n_obs <- length(observed); n_tot <- length(item_ids)
  if (n_obs < n_tot) {
    if (missing == "error") {
      stop(sprintf("Missing response(s) for item(s): %s (missing = 'error').",
                   paste(setdiff(item_ids, observed), collapse = ", ")),
           call. = FALSE)
    }
    if (missing == "na" || n_obs == 0L) {
      return(list(score = NA_real_, used = observed))
    }
    # prorate: scale the observed aggregate up to the full item count
    agg <- .aggregate(v[observed], aggregation)
    score <- if (aggregation == "mean") agg else agg * (n_tot / n_obs)
    return(list(score = score, used = observed))
  }
  list(score = .aggregate(v[observed], aggregation), used = observed)
}

# Per-subscale scores.
computeSubscales <- function(instrument, vals, missing) {
  if (!length(instrument@subscales)) return(numeric(0))
  out <- vapply(names(instrument@subscales), function(nm) {
    .score_set(vals, instrument@subscales[[nm]], instrument@aggregation,
               missing)$score
  }, numeric(1))
  stats::setNames(out, names(instrument@subscales))
}

# Interpretation stratum for a total score. A value inside a band's
# [lower, upper] gets that band (the first, if bands overlap). A fractional total
# - from proration or mean aggregation - that lands in a gap between otherwise
# contiguous integer bands is assigned to the nearest band, so a valid prorated
# score is still classified. Values below the lowest band or above the highest
# are out of range and return NA.
assignStratum <- function(instrument, total) {
  strata <- instrument@strata
  if (is.na(total) || !length(strata)) return(NA_character_)
  for (s in strata) {
    if (total >= s$lower && total <= s$upper) return(as.character(s$label))
  }
  lowers <- vapply(strata, function(s) s$lower, numeric(1))
  uppers <- vapply(strata, function(s) s$upper, numeric(1))
  if (total < min(lowers) || total > max(uppers)) return(NA_character_)
  dist <- vapply(strata, function(s)
    if (total < s$lower) s$lower - total else total - s$upper, numeric(1))
  as.character(strata[[which.min(dist)]]$label)
}

#' Score item responses against a clinical instrument
#'
#' Validates a set of item responses against a [ClinicalInstrument], aggregates
#' them into the total and subscale scores under the chosen missing-data policy,
#' and assigns the interpretation stratum.
#'
#' @param instrument A [ClinicalInstrument], or an instrument id resolved via
#'   [getInstrument()].
#' @param items A named numeric vector (item id -> response), a one-row
#'   data.frame, or an unnamed vector in the instrument's item order.
#' @param missing Missing-data policy: `"error"` (default; any missing item is
#'   an error), `"prorate"` (scale the observed items up to the full count) or
#'   `"na"` (return `NA` for any score with a missing item).
#' @param subject_id Optional subject identifier stored on the result.
#' @param timestamp Optional timestamp stored on the result.
#' @return A [ClinicalScore].
#' @seealso [ClinicalInstrument], [getInstrument()]
#' @export
#' @examples
#' inst <- ClinicalInstrument(
#'   id = "toy", items = c("q1", "q2", "q3"),
#'   item_ranges = list(q1 = c(0, 4), q2 = c(0, 4), q3 = c(0, 4)))
#' scoreInstrument(inst, c(q1 = 2, q2 = 3, q3 = 4))
scoreInstrument <- function(instrument, items,
                            missing = c("error", "prorate", "na"),
                            subject_id = NA_character_,
                            timestamp = NA_character_) {
  missing <- match.arg(missing)
  if (is.character(instrument)) instrument <- getInstrument(instrument)
  stopifnot(is(instrument, "ClinicalInstrument"))

  vals <- validateItems(instrument, items)
  vals <- .apply_recode(instrument, vals)
  subs <- computeSubscales(instrument, vals, missing)

  # For a sum-aggregated instrument whose subscales PARTITION the items (each
  # item in exactly one subscale), the total must equal the sum of the (possibly
  # prorated) subscale scores, so the total = sum(subscales) invariant holds
  # under proration exactly as in the complete case. Overlapping subscales (e.g.
  # a FIM motor subscale that is the union of the finer domains) would double
  # count, so they - like partial coverage, no subscales, or mean aggregation -
  # fall back to prorating the total over the whole instrument.
  subs_items <- unlist(instrument@subscales)
  covers_all <- length(subs) > 0 &&
    setequal(subs_items, instrument@items) &&
    length(subs_items) == length(instrument@items)
  if (instrument@aggregation == "sum" && covers_all) {
    total <- if (any(is.na(subs))) NA_real_ else sum(subs)
    used <- unique(unlist(lapply(names(instrument@subscales), function(nm)
      instrument@items[instrument@items %in% instrument@subscales[[nm]] &
                         !is.na(vals[instrument@items])])))
  } else {
    total_res <- .score_set(vals, instrument@items, instrument@aggregation,
                            missing)
    total <- total_res$score; used <- total_res$used
  }
  stratum <- assignStratum(instrument, total)

  new("ClinicalScore",
      instrument_id = instrument@id, total = total,
      subscales = subs, stratum = stratum, items_used = used,
      missing_handling = missing,
      timestamp = as.character(timestamp),
      subject_id = as.character(subject_id))
}
