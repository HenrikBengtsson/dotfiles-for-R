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
#' @import startup
startup_toolbox({
options_tracker <- local({
  nono <- list(
    ## Package 'base':
    stringsAsFactors = TRUE,
    
    ## Package 'stats':
    contrasts = c(unordered = "contr.treatment", ordered = "contr.poly"),
    na.action = "na.omit",
    ts.eps = 1e-5,
    ts.S.compat = FALSE
  )

  nono_msg <- function(...) {
    msg <- sprintf(...)
    msg <- sprintf("No-no warning: %s", msg)
    message(msg)
  }
  
  function(...) {
    for (name in names(nono)) {
      preferred <- nono[[name]]
      value <- getOption(name)
      if (all(value == preferred)) next
      nono_msg("Option %s was changed from its preferred value (%s): %s", sQuote(name), sQuote(paste(deparse(preferred), collapse = "; ")), sQuote(paste(deparse(value), collapse = "; ")))
    }
    TRUE
  }
})
})

invisible(addTaskCallback(options_tracker, name = "Options tracker"))
