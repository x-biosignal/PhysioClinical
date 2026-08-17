# Package-load hook: anchor the instrument-registry cache in an environment
# created at load time (not a top-level binding), so it survives lazy-load and
# package reloads (see the WSF-10 registry lesson).

.clin_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  if (is.null(.clin_env$instruments)) {
    .clin_env$instruments <- list()
    .clin_env$loaded <- FALSE
  }
  invisible()
}

`%||%` <- function(a, b) if (is.null(a)) b else a
