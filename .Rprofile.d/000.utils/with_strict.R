.with_defaults <- function() {
  ## Default settings
  denvs <- c(
    "_R_CHECK_LENGTH_1_CONDITION_" = "FALSE",
    "_R_CHECK_LENGTH_1_LOGIC2_"    = "FALSE"
  )
  dopts <- list(
    warn                  = 0L,
    warnPartialMatchArgs  = FALSE,
    warnPartialMatchAttr  = FALSE,
    warnPartialMatchDolla = FALSE
  )

  list(options = dopts, envs = denvs)
}

with_nonstrict <- function(expr, envir = parent.frame(), ...) {
  defaults <- .with_defaults()
  oopts <- options()[names(defaults$options)]
  oenvs <- Sys.getenv(names(defaults$envs))

  on.exit({
    do.call(Sys.setenv, args = as.list(oenvs))
    options(oopts)
  })
  
  ## Evaluate expression with factory defaults
  do.call(Sys.setenv, args = as.list(defaults$envs))
  options(defaults$options)
  res <- withVisible(eval(expr, envir = envir, enclos = baseenv()))
  
  if (isTRUE(res$visible)) {
    res$value
  } else {
    invisible(res$value)
  }
}
