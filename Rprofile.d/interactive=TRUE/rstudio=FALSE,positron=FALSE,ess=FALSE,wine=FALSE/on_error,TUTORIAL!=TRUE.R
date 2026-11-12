#' Tweak how errors are handled
#'
#' Options that are set:
#' * `error`
#'
#' @author Henrik Bengtsson
#'
#' @imports utils
options(error = function() {
  ## Close any open 'stdout' sinks including
  ## any active capture.output()
  replicate(sink.number(), sink(NULL))
  if (interactive()) utils::recover()
})
