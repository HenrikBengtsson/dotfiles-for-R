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

addTaskCallback(rng_tracker, name = "RNG tracker")
