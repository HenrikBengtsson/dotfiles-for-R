#' Track all calls to closeAllConnections()
#'
#' @param action (character) What action to take when called.
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
track_closeAllConnections <- function(action = c("error", "warning"), enable = TRUE) {
  action <- match.arg(action)
  stopifnot(is.logical(enable), length(enable) == 1L, !is.na(enable))

  ## Always disable
  suppressMessages({
    untrace(base::closeAllConnections, where = baseenv())
  })

  if (enable) {
    tracer <- if (action == "error") {
      quote(stop("[UNSAFE CODE] Detected a call to closeAllConnections(), but prevented it from taking place", call. = TRUE))
    } else {
      quote(warning("[UNSAFE CODE] Detected a call to closeAllConnections(). Please not that it is never a good idea to call this function", call. = TRUE, immediate. = TRUE))
    }
    
    suppressMessages({
      trace(base::closeAllConnections, where = baseenv(), print = FALSE,
            at = 1L, tracer = tracer)
    })
  }

  invisible()
}
