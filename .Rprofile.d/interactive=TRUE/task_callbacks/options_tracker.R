#' Warn when certain R options have been changed
#'
#' Options that are monitored:
#' * `stringsAsFactors`
#' * `contrasts`
#' * `na.action`
#' * `ts.eps`
#' * `ts.S.compat`
#'
#' @author Henrik Bengtsson
#'
#' @imports startup
startup_toolbox({
options_tracker <- local({
  ## Don't use options() here because other options might be added during
  ## R startup process after this tracker is initiated
  last <- NULL
  
  nono <- list(
    ## Package 'base':
    stringsAsFactors = if (getRversion() >= "4.0.0") FALSE else TRUE,
    
    ## Package 'stats':
    contrasts = c(unordered = "contr.treatment", ordered = "contr.poly"),
    na.action = "na.omit",
    ts.eps = 1e-5,
    ts.S.compat = FALSE
  )

  note <- function(..., prefix = "TRACKER: ") {
    msg <- sprintf(...)
    msg <- paste(prefix, msg, sep = "")
    if (requireNamespace("crayon", quietly=TRUE))
      msg <- crayon::blurred(msg)
    message(msg)
  }
  
  function(expr, value, ok, visible) {
    current <- options()
    if (!is.null(last)) {
      msg <- NULL
      names <- names(current)
      names_last <- names(last)

      ## Options added?
      changed <- setdiff(names, names_last)
      if (length(changed) > 0L) {
        msg <- c(msg, sprintf("Options added: [n=%d] %s.", length(changed), paste(sQuote(changed), collapse = ", ")))
      }
      
      ## Options removed?
      changed <- setdiff(names_last, names)
      if (length(changed) > 0L) {
        msg <- c(msg, sprintf("Options removed: [n=%d] %s.", length(changed), paste(sQuote(changed), collapse = ", ")))
      }
      
      ## Options changed?
      changed <- intersect(names, names_last)
      changed <- setdiff(changed, "prompt")
      
      for (kk in seq_along(changed)) {
        name <- changed[kk]
        if (identical(current[[name]], last[[name]])) changed[kk] <- ""
      }
      changed <- changed[nzchar(changed)]
      if (length(changed) > 0L) {
        msg <- c(msg, sprintf("Options changed: [n=%d] %s.", length(changed), paste(sQuote(changed), collapse = ", ")))
      }
      if (length(msg) > 0L) {
        note(paste(msg, collapse = " "))
      }
    }
    last <<- current
    
    for (name in names(nono)) {
      preferred <- nono[[name]]
      value <- getOption(name)
      if (all(value == preferred)) next
      note("Option %s was changed from its preferred value (%s): %s", sQuote(name), sQuote(paste(deparse(preferred), collapse = "; ")), sQuote(paste(deparse(value), collapse = "; ")), prefix = "TRACKER: [DANGEROUS] ")
    }
    
    TRUE
  }
})
})

invisible(addTaskCallback(options_tracker, name = "Options tracker"))
