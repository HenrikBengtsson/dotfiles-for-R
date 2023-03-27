#' Save the R command-line history upon exit
#'
#' @author Henrik Bengtsson
#' @imports utils
.Last <- function() {
  if (base::interactive()) {
    file <- Sys.getenv("R_HISTFILE", ".Rhistory")
    try(utils::savehistory(file), silent = TRUE)
  }
}
