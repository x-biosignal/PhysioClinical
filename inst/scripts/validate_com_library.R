#!/usr/bin/env Rscript
# validate_com_library.R -- reproduce published MDC/MCID reference values from
# the bundled clinimetric store and confirm they match the literature. Run with:
#   Rscript inst/scripts/validate_com_library.R
# Exits non-zero if any stored value departs from its published anchor.

suppressWarnings(suppressMessages(library(PhysioClinical)))

# Published anchors, each with a real DOI. `expected` is the value reported in
# the cited paper; `tol` is the check tolerance (values are exact table entries).
anchors <- list(
  list(instrument = "BBS", statistic = "MDC",
       population = "elderly_baseline_45_56", expected = 3.30, tol = 0.05,
       reference = "Donoghue & Stokes 2009, doi:10.2340/16501977-0337 (45-56 stratum)"),
  list(instrument = "FMA-UE", statistic = "MCID_anchor",
       population = "chronic_stroke_minimal", expected = 4.25, tol = 0.05,
       reference = "Page et al. 2012, doi:10.2522/ptj.20110009 (minimal impairment)"),
  list(instrument = "6MWT", statistic = "MCID_dist", population = "older_adults",
       expected = 20.0, tol = 0.5,
       reference = "Perera et al. 2006, doi:10.1111/j.1532-5415.2006.00701.x (small meaningful change)"),
  list(instrument = "FIM", statistic = "MCID_anchor", population = "stroke",
       expected = 22.0, tol = 0.5,
       reference = "Beninato et al. 2006, doi:10.1016/j.apmr.2005.08.112")
)

rows <- lapply(anchors, function(a) {
  got <- getClinimetric(a$instrument, a$statistic, population = a$population)
  value <- if (is.data.frame(got)) got$value[1] else got
  ok <- is.finite(value) && abs(value - a$expected) <= a$tol
  data.frame(instrument = a$instrument, statistic = a$statistic,
             population = a$population, stored = value, published = a$expected,
             match = ok, reference = a$reference, stringsAsFactors = FALSE)
})
result <- do.call(rbind, rows)

cat("Clinimetric library validation (stored vs. published)\n")
cat("=====================================================\n")
print(result[, c("instrument", "statistic", "stored", "published", "match")],
      row.names = FALSE)
cat("\nProvenance:\n")
for (i in seq_len(nrow(result))) {
  cat(sprintf("  %-6s %-11s  %s\n", result$instrument[i], result$statistic[i],
              result$reference[i]))
}

n_ok <- sum(result$match)
cat(sprintf("\n%d / %d published values reproduced.\n", n_ok, nrow(result)))
if (n_ok < 3L) {
  stop("fewer than 3 published clinimetric values reproduced.", call. = FALSE)
}
if (!all(result$match)) {
  stop("a stored clinimetric value departs from its published anchor.",
       call. = FALSE)
}
invisible(result)
