#' Like debugonce() but for options(error = recover())
#'
#' @param close_sinks If TRUE, all active "output" sinks are closed before
#' [base::recover()] is called. Without this, all of `recover()`'s output
#' will be sinked and not visible to the user.
#'
#' @author
#' Henrik Bengtsson, adopted from original idea by Nicholas Tierney and
#' Thomas Lumley <https://twitter.com/tslumley/status/1494119934808719363>.
#'
#' @importFrom utils recover
recover_once <- function(close_sinks = TRUE) {
  if (!interactive()) {
    stop("utils::recover() works only in interactive R sessions")
  }
  
  old_opts <<- options(error = function(...) {
    ## Undo 'error'
    options(error = old_opts$error)

    ## Close any open 'stdout' sinks including any active capture.output()?
    if (close_sinks) replicate(sink.number(), sink(NULL))

    utils::recover(...)
  })
}
