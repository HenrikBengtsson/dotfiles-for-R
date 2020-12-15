#' Warn when packages are loaded or unloaded
#'
#' @author Henrik Bengtsson
#'
#' @imports startup
startup_toolbox({
package_tracker <- local({
  last <- loadedNamespaces()
  
  function(expr, value, ok, visible) {
    if (!isTRUE(getOption("tracker.packages", TRUE))) return(TRUE)
    curr <- loadedNamespaces()
    if (!identical(curr, last)) {
      diff <- list(
        loaded   = sort(setdiff(curr, last)),
        unloaded = sort(setdiff(last, curr))
      )
      diff <- vapply(names(diff), FUN = function(name) {
        vars <- diff[[name]]
        nvars <- length(vars)
        if (nvars == 0L) return(NA_character_)
        sprintf("%d package%s %s (%s)",
                nvars, if (nvars == 1) "" else "s", name,
                paste(sQuote(vars), collapse = ", "))
      }, FUN.VALUE = NA_character_)
      diff <- diff[!is.na(diff)]
      msg <- paste("TRACKER: loadedNamespaces() changed:", diff)
      if (requireNamespace("crayon", quietly=TRUE)) msg <- crayon::blurred(msg)
      lapply(msg, FUN = message)
      last <<- curr
    }
    TRUE
  }
})
})

invisible(addTaskCallback(package_tracker, name = "Package tracker"))
