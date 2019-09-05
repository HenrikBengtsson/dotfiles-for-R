#' Warn when the .Random.seed has changed
#'
#' Global variables that are monitored:
#' * `.Random.seed`
#'
#' @author Henrik Bengtsson
#'
#' @import startup
startup_toolbox({
rng_tracker <- local({
  last <- .GlobalEnv$.Random.seed
  function(...) {
    curr <- .GlobalEnv$.Random.seed
    if (!identical(curr, last)) {
      warning(".Random.seed changed", call. = FALSE, immediate. = TRUE)
      last <<- curr
    }
    TRUE
  }
})
})

invisible(addTaskCallback(rng_tracker, name = "RNG tracker"))
