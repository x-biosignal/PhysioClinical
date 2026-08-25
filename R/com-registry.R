# Instrument registry: a load-once cache of the bundled YAML instrument specs,
# extensible at runtime with registerInstrument().

# The cache lives in .clin_env (created in zzz.R); a getter guarantees it exists
# even if .onLoad has not run (e.g. under devtools::load_all edge cases).
.registry <- function() {
  if (is.null(.clin_env$instruments)) {
    .clin_env$instruments <- list(); .clin_env$loaded <- FALSE
  }
  .clin_env
}

# Build a ClinicalInstrument from a parsed YAML spec list.
.instrument_from_spec <- function(spec) {
  items <- as.character(spec$items)
  ranges <- spec$item_ranges
  # allow item_ranges as a named list or as a list of two-element vectors
  ranges <- lapply(ranges, function(r) as.numeric(unlist(r)))
  subs <- spec$subscales %||% list()
  subs <- lapply(subs, as.character)
  strata <- lapply(spec$strata %||% list(), function(s)
    list(label = as.character(s$label), lower = as.numeric(s$lower),
         upper = as.numeric(s$upper)))
  item_values <- lapply(spec$item_values %||% list(),
                        function(v) as.numeric(unlist(v)))
  # item_recode: a per-item map from the raw response (YAML key) to the scored
  # value, e.g. item_recode: {q03: {1: 0, 2: 50, 3: 100}}
  item_recode <- lapply(spec$item_recode %||% list(), function(m) {
    m <- unlist(m)
    stats::setNames(as.numeric(m), names(m))
  })
  ClinicalInstrument(
    id = spec$id, name = spec$name %||% NA_character_,
    version = as.character(spec$version %||% NA_character_),
    items = items, item_ranges = ranges,
    item_type = as.character(spec$item_type %||% "interval"),
    subscales = subs, aggregation = spec$aggregation %||% "sum",
    direction = spec$direction %||% "higher_better", strata = strata,
    item_values = item_values, item_recode = item_recode,
    source_ref = spec$source_ref %||% NA_character_)
}

# Lazily load the bundled YAML specs the first time the registry is touched.
.ensure_loaded <- function() {
  reg <- .registry()
  if (isTRUE(reg$loaded)) return(invisible())
  dir <- system.file("extdata", "instruments", package = "PhysioClinical")
  if (nzchar(dir) && dir.exists(dir) &&
      requireNamespace("yaml", quietly = TRUE)) {
    files <- list.files(dir, pattern = "\\.ya?ml$", full.names = TRUE)
    files <- files[basename(files) != "schema.yaml"]
    for (f in files) {
      spec <- tryCatch(yaml::read_yaml(f), error = function(e) NULL)
      # skip a file that failed to parse, parsed to a non-mapping, or lacks an id
      if (is.null(spec) || !is.list(spec) || is.null(spec$id)) next
      inst <- tryCatch(.instrument_from_spec(spec), error = function(e) {
        warning(sprintf("Skipping instrument spec '%s': %s",
                        basename(f), conditionMessage(e)), call. = FALSE)
        NULL
      })
      # a user registration made before the first load takes precedence
      if (!is.null(inst) && is.null(reg$instruments[[inst@id]])) {
        reg$instruments[[inst@id]] <- inst
      }
    }
  }
  reg$loaded <- TRUE
  invisible()
}

#' List available clinical instruments
#'
#' @return A character vector of registered instrument ids.
#' @seealso [getInstrument()], [registerInstrument()]
#' @export
listInstruments <- function() {
  .ensure_loaded()
  sort(names(.registry()$instruments))
}

#' Retrieve a registered clinical instrument
#'
#' @param id Instrument identifier.
#' @return The [ClinicalInstrument].
#' @seealso [listInstruments()], [registerInstrument()]
#' @export
getInstrument <- function(id) {
  .ensure_loaded()
  inst <- .registry()$instruments[[id]]
  if (is.null(inst)) {
    stop(sprintf("No instrument registered with id '%s'. Available: %s",
                 id, paste(listInstruments(), collapse = ", ")), call. = FALSE)
  }
  inst
}

#' Register a clinical instrument
#'
#' Adds an instrument to the registry, either a [ClinicalInstrument] object, a
#' parsed-spec list, or the path to a YAML spec file.
#'
#' @param spec A [ClinicalInstrument], a spec list, or a path to a `.yaml` file.
#' @param overwrite Replace an existing instrument with the same id? Default
#'   `FALSE` (an existing id is an error).
#' @return Invisibly, the registered [ClinicalInstrument].
#' @seealso [getInstrument()], [listInstruments()]
#' @export
#' @examples
#' inst <- ClinicalInstrument(id = "toy2", items = c("a", "b"),
#'   item_ranges = list(a = c(0, 1), b = c(0, 1)))
#' registerInstrument(inst)
registerInstrument <- function(spec, overwrite = FALSE) {
  .ensure_loaded()
  if (is.character(spec) && length(spec) == 1L && file.exists(spec)) {
    if (!requireNamespace("yaml", quietly = TRUE)) {
      stop("Reading a YAML spec needs the yaml package.", call. = FALSE)
    }
    spec <- yaml::read_yaml(spec)
  }
  inst <- if (is(spec, "ClinicalInstrument")) spec else .instrument_from_spec(spec)
  reg <- .registry()
  if (!overwrite && !is.null(reg$instruments[[inst@id]])) {
    stop(sprintf("Instrument '%s' is already registered; use overwrite = TRUE.",
                 inst@id), call. = FALSE)
  }
  reg$instruments[[inst@id]] <- inst
  invisible(inst)
}
