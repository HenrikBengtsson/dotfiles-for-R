#' Warn when environment variables have been changed
#'
#' @author Henrik Bengtsson
#'
#' @imports startup
startup_toolbox({
envvars_tracker <- local({
  last <- NULL
  
  note <- function(..., prefix = "TRACKER: ") {
    msg <- sprintf(...)
    msg <- paste(prefix, msg, sep = "")
    if (requireNamespace("crayon", quietly=TRUE))
      msg <- crayon::blurred(msg)
    message(msg)
  }
  
  function(expr, value, ok, visible) {
    current <- as.list(Sys.getenv())
    if (!is.null(last)) {
      msg <- NULL
      names <- names(current)
      names_last <- names(last)

      ## Envvars added?
      changed <- setdiff(names, names_last)
      if (length(changed) > 0L) {
        msg <- c(msg, sprintf("Environment variables added: [n=%d] %s.", length(changed), paste(sQuote(changed), collapse = ", ")))
      }
      
      ## Environment variables removed?
      changed <- setdiff(names_last, names)
      if (length(changed) > 0L) {
        msg <- c(msg, sprintf("Environment variables removed: [n=%d] %s.", length(changed), paste(sQuote(changed), collapse = ", ")))
      }
      
      ## Environment variables changed?
      changed <- intersect(names, names_last)
      changed <- setdiff(changed, "prompt")
      
      for (kk in seq_along(changed)) {
        name <- changed[kk]
        if (identical(current[[name]], last[[name]])) changed[kk] <- ""
      }
      changed <- changed[nzchar(changed)]
      if (length(changed) > 0L) {
        msg <- c(msg, sprintf("Environment variables changed: [n=%d] %s.", length(changed), paste(sQuote(changed), collapse = ", ")))
      }
      if (length(msg) > 0L) {
        note(paste(msg, collapse = " "))
      }
    }
    last <<- current
    
    TRUE
  }
})
})

invisible(addTaskCallback(envvars_tracker, name = "Environment-variable tracker"))
