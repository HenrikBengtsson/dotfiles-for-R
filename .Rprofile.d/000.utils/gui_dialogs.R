gui_dialogs <- local({
  gui_options <- function() {
    names <- c("askYesNo", "menu.graphics")
    res <- lapply(names, FUN = getOption)
    names(res) <- names
    res
  }
  
  defaults <- gui_options()
  
  function(which = c("list", "off", "default", "on")) {
    which <- match.arg(which)
    if (which == "list") {
      return(gui_options())
    } else if (which == "off") {
      oopts <- options(
        menu.graphics = FALSE,
        askYesNo = NULL
      )
    } else if (which == "default") {
      oopts <- options(defaults)
    } else if (which == "on") {
      opts <- defaults
      opts$menu.graphics <- TRUE
      oopts <- options(opts)
      startup_warn("The implementation of gui_dialogs(\"on\") is ad hoc; it uses gui_dialogs(\"default\") and enables some obvious options, but it is not agile to operating system and available features in some GUI")
    }
    invisible(oopts)
  }
})
