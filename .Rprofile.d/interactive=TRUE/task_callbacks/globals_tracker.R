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
  startup <- TRUE
  last <- ls(envir = .GlobalEnv, all.names = TRUE)
  
  function(expr, value, ok, visible) {
    if (!isTRUE(getOption("tracker.globals", TRUE))) return(TRUE)
    curr <- ls(envir = .GlobalEnv, all.names = TRUE)

    ## Avoid reporting on changes occuring during startup
    if (startup) {
      startup <<- FALSE
      last <<- curr
    }
    
    if (!identical(curr, last)) {
      diff <- list(
        added   = setdiff(curr, last),
        removed = setdiff(last, curr)
      )

      ## Filter out accepted additions
      if (ok && length(diff$added) > 0L && !is.symbol(expr)) {
        fcn <- expr[[1]]
        accept <- c("<-", "<<-")
        drop <- FALSE
        for (name in accept) {
          if (fcn == as.symbol(name)) {
            drop <- TRUE
            break
          }
        }
        if (drop) {
          ## If we do x[2] <- value and for some reason end up here,
          ## which we shouldn't, 'name' will become "x[2]" and therefore
          ## 'x' will _not_ be dropped.
          name <- as.character(expr[[2]])
          diff$added <- setdiff(diff$added, name)
        }
      }

      ## Still something to report?
      if (length(diff$added) + length(diff$removed) > 0L) {
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
        if (requireNamespace("crayon", quietly=TRUE)) msg <- crayon::bold(crayon::yellow(msg))
        lapply(msg, FUN = message)
      }
      
      last <<- curr
    }
    TRUE
  }
})
})

invisible(addTaskCallback(globals_tracker, name = ".GlobalEnv tracker"))
