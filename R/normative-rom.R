# Joint range-of-motion (goniometry) reference values, loaded from the packaged,
# provenanced table. These are consensus clinical reference values (AAOS), not a
# distribution-based normative model: they carry a single reference angle per
# joint motion, so they support reference / side-to-side comparison but NOT a
# z-score (which needs a mean and SD). For an age/sex-stratified z-score, build a
# GovernedNormativeReference from a cohort dataset (e.g. Soucie et al. 2011) and
# use normativeZScore(); this table is the quick clinical yardstick.

# Load-once cache of the packaged ROM reference table (mirrors the clinimetric
# constants store).
.rom_cache <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      f <- system.file("extdata", "normative", "rom_reference.csv",
                       package = "PhysioClinical")
      if (!nzchar(f)) {
        stop("the packaged ROM reference file is missing.", call. = FALSE)
      }
      cache <<- utils::read.csv(f, stringsAsFactors = FALSE, encoding = "UTF-8")
    }
    cache
  }
})

#' Joint range-of-motion reference values (goniometry)
#'
#' Returns the packaged normal active range-of-motion reference values for the
#' major peripheral joints (shoulder, elbow, forearm, wrist, hip, knee, ankle).
#' These are the consensus clinical goniometry reference angles (in degrees) of
#' the American Academy of Orthopaedic Surgeons, as tabulated by Norkin & White,
#' *Measurement of Joint Motion*. They are single reference angles (not a
#' distribution), so use [romNormalcy()] for a reference / side-to-side
#' comparison; for a stratified z-score build a
#' [GovernedNormativeReference()] from a cohort dataset and use
#' [normativeZScore()].
#'
#' @param joint Optional joint to filter by (e.g. `"knee"`; case insensitive).
#' @param motion Optional motion to filter by (e.g. `"flexion"`; case
#'   insensitive).
#' @return A `data.frame` with `joint`, `motion`, `plane`, `reference_deg` and
#'   `source`.
#' @seealso [romNormalcy()], [normativeZScore()]
#' @references American Academy of Orthopaedic Surgeons (1965). *Joint Motion:
#'   Method of Measuring and Recording*. Norkin CC, White DJ. *Measurement of
#'   Joint Motion: A Guide to Goniometry*. F.A. Davis.
#' @export
#' @examples
#' romReference("knee")
#' romReference(motion = "flexion")
romReference <- function(joint = NULL, motion = NULL) {
  tbl <- .rom_cache()
  if (!is.null(joint)) {
    tbl <- tbl[tolower(tbl$joint) == tolower(joint), , drop = FALSE]
  }
  if (!is.null(motion)) {
    tbl <- tbl[tolower(tbl$motion) == tolower(motion), , drop = FALSE]
  }
  rownames(tbl) <- NULL
  tbl
}

#' Compare a measured joint ROM to the reference (and the other side)
#'
#' Compares a measured joint range of motion against the packaged reference angle
#' (see [romReference()]) and, when supplied, the contralateral (usually
#' unaffected) side - the two comparisons clinicians read a goniometry
#' measurement against.
#'
#' @param measured Measured range of motion, in degrees.
#' @param joint,motion The joint and motion (case insensitive); must identify a
#'   single reference row.
#' @param contralateral Optional measured ROM of the other side, in degrees.
#' @return A one-row `data.frame` (class `"rom_normalcy"`) with `reference_deg`,
#'   `percent_of_normal` (`NA` for an extension-to-neutral motion whose reference
#'   is 0 deg), `deficit_vs_reference` (reference minus measured) and `limited`
#'   (measured below reference); plus `contralateral_deg`,
#'   `deficit_vs_contralateral` and `percent_of_contralateral` when a
#'   contralateral value is given.
#' @seealso [romReference()]
#' @export
#' @examples
#' romNormalcy(100, "knee", "flexion")
#' romNormalcy(100, "knee", "flexion", contralateral = 130)
romNormalcy <- function(measured, joint, motion, contralateral = NULL) {
  ref <- romReference(joint, motion)
  if (nrow(ref) == 0L) {
    avail <- romReference(joint)
    stop(sprintf("no ROM reference for joint '%s' motion '%s'.%s",
                 joint, motion,
                 if (nrow(avail)) paste0(" Available motions for '", joint,
                   "': ", paste(avail$motion, collapse = ", "), ".") else
                   " (unknown joint)"), call. = FALSE)
  }
  if (nrow(ref) > 1L) {
    stop("'joint' and 'motion' must identify a single reference row.",
         call. = FALSE)
  }
  measured <- as.numeric(measured)
  if (length(measured) != 1L || !is.finite(measured)) {
    stop("'measured' must be a single finite numeric (degrees).", call. = FALSE)
  }
  refdeg <- ref$reference_deg[1L]
  pct <- if (is.finite(refdeg) && refdeg != 0) 100 * measured / refdeg else NA_real_
  out <- data.frame(
    joint = ref$joint[1L], motion = ref$motion[1L], plane = ref$plane[1L],
    measured_deg = measured, reference_deg = refdeg,
    percent_of_normal = pct, deficit_vs_reference = refdeg - measured,
    limited = measured < refdeg, source = ref$source[1L],
    stringsAsFactors = FALSE)
  if (!is.null(contralateral)) {
    contra <- as.numeric(contralateral)
    if (length(contra) != 1L || !is.finite(contra)) {
      stop("'contralateral' must be a single finite numeric (degrees).",
           call. = FALSE)
    }
    out$contralateral_deg <- contra
    out$deficit_vs_contralateral <- contra - measured
    out$percent_of_contralateral <-
      if (contra != 0) 100 * measured / contra else NA_real_
  }
  class(out) <- c("rom_normalcy", "data.frame")
  out
}

#' @export
print.rom_normalcy <- function(x, ...) {
  y <- x
  class(y) <- "data.frame"
  cat(sprintf("%s %s (%s): %g deg vs reference %g deg",
              y$joint[1L], y$motion[1L], y$plane[1L],
              y$measured_deg[1L], y$reference_deg[1L]))
  if (is.finite(y$percent_of_normal[1L])) {
    cat(sprintf(" (%.0f%% of normal, deficit %g deg)",
                y$percent_of_normal[1L], y$deficit_vs_reference[1L]))
  }
  if (!is.null(y$contralateral_deg)) {
    cat(sprintf("; contralateral %g deg (deficit %g deg)",
                y$contralateral_deg[1L], y$deficit_vs_contralateral[1L]))
  }
  cat(sprintf("  [%s]\n", y$source[1L]))
  invisible(x)
}
