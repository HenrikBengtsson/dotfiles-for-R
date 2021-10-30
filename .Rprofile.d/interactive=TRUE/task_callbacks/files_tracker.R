#' Warn when files are added or removed
#'
#' Set R option \option{tracker.files} to `FALSE` to disable.
#'
#' @author Henrik Bengtsson
#'
#' @imports startup
startup_toolbox({
globals_tracker <- local({
  cache <- list()
  cache[[getwd()]] <- dir(all.files = TRUE)
  
  function(expr, value, ok, visible) {
    if (!isTRUE(getOption("tracker.files", TRUE))) return(TRUE)
    pwd <- getwd()
    last <- cache[[pwd]]
    curr <- dir(all.files = TRUE)
    if (!identical(curr, last)) {
      diff <- list(
        added   = setdiff(curr, last),
        removed = setdiff(last, curr)
      )
      diff <- vapply(names(diff), FUN = function(name) {
        vars <- diff[[name]]
        nvars <- length(vars)
        if (nvars == 0L) return(NA_character_)
        sprintf("%d file%s %s (%s)",
                nvars, if (nvars == 1) "" else "s", name,
                paste(sQuote(vars), collapse = ", "))
      }, FUN.VALUE = NA_character_)
      diff <- diff[!is.na(diff)]
      msg <- paste("TRACKER: ", diff)
      if (requireNamespace("crayon", quietly=TRUE)) msg <- crayon::blurred(msg)
      lapply(msg, FUN = message)
      cache[[pwd]] <<- curr
    }
    TRUE
  }
})
})

invisible(addTaskCallback(globals_tracker, name = "Files tracker"))
