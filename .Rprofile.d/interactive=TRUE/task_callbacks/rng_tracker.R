#' Warn when the .Random.seed has changed
#'
#' Global variables that are monitored:
#' * `.Random.seed`
#'
#' @author Henrik Bengtsson
#'
#' @imports startup
startup_toolbox({
rng_tracker <- local({
  last <- .GlobalEnv$.Random.seed
  
  function(...) {
    curr <- .GlobalEnv$.Random.seed
    if (!identical(curr, last)) {
      msg <- "TRACKER: .Random.seed changed"
      if (requireNamespace("crayon", quietly=TRUE)) msg <- crayon::blurred(msg)
      message(msg)
      last <<- curr
    }
    TRUE
  }
})
})

invisible(addTaskCallback(rng_tracker, name = "RNG tracker"))
