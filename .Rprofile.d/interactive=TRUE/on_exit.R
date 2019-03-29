# Save command-line history upon exit
.Last <- function() {
  if (base::interactive()) {
    file <- Sys.getenv("R_HISTFILE", ".Rhistory")
    try(utils::savehistory(file), silent = TRUE)
  }
}
