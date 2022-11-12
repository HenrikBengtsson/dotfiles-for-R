#' Trace packages that update the random number generation (RNG) state when loaded
#'
#' @param action (character) Enable or disable tracing.
#'
#' @return Nothing.
#'
#' @details
#' This tracer injects itself as a tracer to [base::loadNamespace()], where
#' it keeps track of the `.Random.seed` in the global environment as packages
#' are _loaded_.  This way it can detect if a package updates the random
#' number generation (RNG) state during load, e.g. when the package's
#' `.onLoad()` function is called.
#' Importantly, currently, it does not detect RNG-state changes when a package
#' is _attached_, e.g. when the package's `.onAttach()` function is called.
#'
#' export
trace_rng_on_load <- function(action = c("on", "off")) {
  action <- match.arg(action)

  ## Always disable
  suppressMessages({
    untrace(loadNamespace, where = baseenv())
  })
  
  if (action == "on") {
    suppressMessages({
      trace(loadNamespace, where = baseenv(), print = FALSE,
            at = 1L, tracer = .tracer_rng_on_load)
    })
  }

  invisible()
}

#' @importFrom digest digest
.tracer_rng_on_load <- local({
  ## To please R CMD check
  package <- state <- NULL
  
  events <- data.frame(package = character(0L), state = character(0L), seed = character(0L))
  
  function(action = c("enter", "exit", "events"), pkgname = envir[["package"]], digest = TRUE, envir = parent.frame()) {
    action <- match.arg(action)
    
    if (action == "enter") {
      if (is.symbol(pkgname)) pkgname <- as.character(pkgname)
      stopifnot(length(pkgname) == 1L, is.character(pkgname))
#      message(sprintf("loadNamespace('%s') ...", pkgname))
      ## Already loaded?
      if (pkgname %in% names(events)) return()

      seed <- globalenv()[[".Random.seed"]]
      seed <- if (is.null(seed)) "<NULL>" else paste(seed, collapse = ",")
      event <- data.frame(package = pkgname, state = "enter", seed = seed)
      events <<- rbind(events, event)
#      str(events)
#      message(sprintf("Recorded events: %s", paste(sprintf("%s:%s", events$package, events$state), collapse = ", ")))
  
      ## Note: Can't use trace(... exit) because loadNamespace() calls
      ## on.exit() internally, which wipes any "exit" tracers.
      setHook(packageEvent(pkgname, "onLoad"), action = "append",
              function(pkgname, ...) {
                .tracer_rng_on_load(action = "exit", pkgname = pkgname)
              })
      return(invisible(events))
    } else if (action == "exit") {
      stopifnot(length(pkgname) == 1L, is.character(pkgname))
      seed <- globalenv()[[".Random.seed"]]
      seed <- if (is.null(seed)) "<NULL>" else paste(seed, collapse = ",")
      event <- data.frame(package = pkgname, state = "exit", seed = seed)

      ## Find most recent 'enter' event
      subset <- base::subset(events, package == pkgname, state = "enter")
      stopifnot(nrow(subset) > 0)
      event_enter <- subset[nrow(subset), ]

      ## Record 'exit' event
      events <<- rbind(events, event)

      ## Nothing to do? RNG state did not change?
      if (seed == event_enter[["seed"]]) {
#        message(sprintf("loadNamespace('%s') ... done", pkgname))
        return(invisible())
      }

      ## Was the new seed set by another package before this package?
      idxs <- vapply(events[["seed"]], FUN.VALUE = NA, FUN = identical, seed)
      events_exit <- base::subset(events[idxs,], state == "exit")
      if (nrow(events_exit) > 0) {
        event_first <- events_exit[1, ]
        source <- event_first[["package"]]
      } else {
        source <- pkgname
      }

      if (source == pkgname) {
        msg <- sprintf("RNG state was updated when loading package %s", sQuote(pkgname))
      } else {
        ns <- getNamespace(pkgname)
        imports <- names(ns[[".__NAMESPACE__."]][["imports"]])
        relationship <- if (source %in% imports) "direct" else "indirect"
        msg <- sprintf("RNG state was updated when loading package %s because of its %s dependency %s", sQuote(pkgname), relationship, sQuote(source))
      }
      warning(msg, call. = FALSE, immediate. = TRUE)
#      message(sprintf("loadNamespace('%s') ... done", pkgname))
      return(invisible(FALSE))
    } else if (action == "events") {
      if (digest) {
        events$seed <- vapply(events$seed, FUN.VALUE = NA_character_, FUN = digest)
      }
      return(events)
    }
  }
})
