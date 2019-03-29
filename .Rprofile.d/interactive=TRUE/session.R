# Save command-line history upon exit
.Last <- function() {
  if (base::interactive()) {
    file <- Sys.getenv("R_HISTFILE", ".Rhistory")
    try(utils::savehistory(file), silent = TRUE)
  }
}

# TAB-completions, cf.
# '[Bioc-devel] tab completion for library()' on 2013-11-13.
utils::rc.settings(ipck = TRUE)
