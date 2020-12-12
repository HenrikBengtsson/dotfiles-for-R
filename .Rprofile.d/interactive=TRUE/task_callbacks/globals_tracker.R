#' Warn when objects are added or removed from the global environment
#'
#' Global variables that are ignored:
#' * `.Random.seed`
#'
#' @author Henrik Bengtsson
#'
#' @imports startup
startup_toolbox({
globals_tracker <- local({
  last <- ls(envir = .GlobalEnv, all.names = TRUE)
  
  function(...) {
    if (!isTRUE(getOption("tracker.globals", TRUE))) return(TRUE)
    curr <- ls(envir = .GlobalEnv, all.names = TRUE)
    if (!identical(curr, last)) {
      diff <- list(
        added   = setdiff(curr, last),
        removed = setdiff(last, curr)
      )
      diff <- vapply(names(diff), FUN = function(name) {
        vars <- diff[[name]]
        nvars <- length(vars)
        if (nvars == 0L) return(NA_character_)
        sprintf("%d variable%s %s (%s)",
                nvars, if (nvars == 1) "" else "s", name,
                paste(sQuote(vars), collapse = ", "))
      }, FUN.VALUE = NA_character_)
      diff <- diff[!is.na(diff)]
      msg <- paste("TRACKER: .GlobalEnv changed:", diff)
      if (requireNamespace("crayon", quietly=TRUE)) msg <- crayon::blurred(msg)
      lapply(msg, FUN = message)
      last <<- curr
    }
    TRUE
  }
})
})

invisible(addTaskCallback(globals_tracker, name = ".GlobalEnv tracker"))
