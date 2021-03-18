sandbox <- local({
  name <- "sandbox"
  stack <- list()
  stack[[name]] <- list(status = "off", .libPaths = NULL)
  
  original <- NULL
  
  details <- function() {
    list(
      status    = stack[[name]]$status,
      .libPaths = .libPaths()
    )
  }
  
  function(action = c("toggle", "on", "off", "status", "details"), name = "sandbox", replace = FALSE) {
    action <- match.arg(action)
    stopifnot(is.character(name), length(name) == 1L, !is.na(name), !grepl(" ", name))
    stopifnot(is.logical(replace), length(replace) == 1L, !is.na(replace))

    ## Make sure 'original' is recorded
    if (is.null(original)) {
      original <<- list(
        .libPaths = .libPaths()
      )
    }


    current <- stack[[name]]
    status <- current$status
    if (is.null(status)) status <- "off"

    if (action == "toggle") action <- switch(status, on="off", off="on")
    if (action == "status") return(status)
    
    if (action == "on" && status == "off") {
      libs <- current$.libPaths
      if (is.null(libs)) {
        lib0 <- original$.libPaths[1]
        lib <- paste0(lib0, "-", name)
        dir.create(lib, showWarnings = FALSE)
        if (!replace) lib <- c(lib, lib0)
	current$.libPaths <- lib
      }
      .libPaths(current$.libPaths)
      current$status <- "on"
    } else if (action == "off" && status == "on") {
      .libPaths(original$.libPaths)
      current$status <- "off"
    }

    stack[[name]] <<- current

    details()
  }
})
