#' Track all calls to closeAllConnections()
#'
#' @param action (character) What action to take when called.
#'
#' @param allow (list) List of functions that are allowed to call
#' `closeAllConnections()` and that this tracker will ignore.
#'
#' @param enable (character) Enable or disable tracking.
#'
#' @return Nothing.
#'
#' @details
#' Calling [base::closeAllConnections()] is a very harsh action.  It closes
#' all open R connections regardless who created them.  It should never be
#' called in an R package.  There's also little reason for calling it from
#' an R script, or even from the R prompt.  If you find yourself having to
#' do so, your R session is probably already in such a bad shape that it's
#' better to restart R all along.
#'
#' This tracker detects whenever `closeAllConnections()` is called.
#' It can then produce an informative warning or and error.  If an error,
#' then no connections will be closed.
#'
#' export
track_closeAllConnections <- function(action = c("error", "warning"), allow = list(base::sys.save.image), enable = TRUE) {
  action <- match.arg(action)
  stopifnot(is.logical(enable), length(enable) == 1L, !is.na(enable))

  stopifnot(
    is.list(allow),
    all(vapply(allow, FUN.VALUE = NA, FUN = is.function))
  )

  ## Always disable
  suppressMessages({
    untrace(base::closeAllConnections, where = baseenv())
  })

  if (enable) {
    expr_action <- if (action == "error") {
      quote({
        msg <- sprintf("%s. However, it was prevented from taking place", msg)
        stop(msg, call. = TRUE)
      })
    } else {
      quote({
        msg <- sprintf("%s. Please not that it is never a good idea to call this function", msg)
        warning(msg, call. = TRUE, immediate. = TRUE)
      })
    }

    tracer <- bquote({
      fcn <- tryCatch(eval(sys.call(which = 1L)[[1]]), error = identity)
      skip <- any(vapply(.(allow), FUN.VALUE = FALSE, FUN = identical, fcn))
      if (!isTRUE(skip)) {
        calls <- sys.calls()
        calls <- calls[seq_len(length(calls) - 5L)]
        if (length(calls) > 0) {
          calls <- lapply(calls, FUN = deparse)
          calls <- unlist(calls, use.names = FALSE)
          calls <- paste(calls, collapse = " -> ")
        } else {
          calls <- "a direct call"
        }
        msg <- sprintf("[UNSAFE CODE] Detected a call to closeAllConnections() via %s", calls)
        .(expr_action)
      }
    })
    
    suppressMessages({
      trace(base::closeAllConnections, where = baseenv(), print = FALSE,
            at = 1L, tracer = tracer)
    })
  }

  invisible()
}
