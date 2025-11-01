tryCatch(startup::startup(all = TRUE), error=function(ex) message(".Rprofile error: ", conditionMessage(ex)))
try(BioconductorX::use(unload = TRUE, timemachine = FALSE), silent = TRUE)

## Register global calling handler for 'progressr' here. We need to
## do it here, because startup::startup() runs within tryCatch()
if (requireNamespace("progressr", quietly = TRUE)) {
  progressr::handlers(global = TRUE)

  ## Workaround for RStudio 2025.09 console bug #16331
  if (nzchar(Sys.getenv("RSTUDIO")) && !nzchar(Sys.getenv("RSTUDIO_TERM")) && exists("RStudio.Version", mode = "function")) {
    invisible(addTaskCallback(function(...) {
      rv <- RStudio.Version()$version
      if (rv >= "2025.09" && rv < "2025.11") {
        message("Workaround for RStudio 2025.09 bug #16331: re-installed progressr global handler")
        progressr::handlers(global = TRUE)
      } else {
        warning("Workaround for RStudio 2025.09 bug #16331: Not needed in RStudio v", rv, ". Please remove task callback 'rstudio::progressr::once' in your Rprofile startup file", call. = FALSE, immediate. = TRUE)
      }
      removeTaskCallback("rstudio::progressr::once")
    }, name = "rstudio::progressr::once"))
  }

  ## Workaround for RStudio 2025.09 console bug #16331
  if (nzchar(Sys.getenv("POSITRON"))) local({
    ver <- numeric_version(Sys.getenv("POSITRON_VERSION"))
    if (ver >= "2025.09") {
      message("Workaround for Positron (>= 2025.09) bug #6892: progressr global handler will be installed *after* the next call has been completed")
      invisible(addTaskCallback(function(...) {
        message("Workaround for Positron (>= 2025.09) bug #6892: re-installed progressr global handler")
        globalCallingHandlers(globalCallingHandlers(NULL))
        removeTaskCallback("positron::progressr::once")
      }, name = "positron::progressr::once"))
    }
  })
}


