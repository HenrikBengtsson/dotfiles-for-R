#' Displays a random forture
#'
#' @author Henrik Bengtsson
#'
#' @imports fortures
try(local({
  f <- suppressWarnings(fortunes::fortune())
  cat(sprintf("Fortune #%s:\n", attr(f, "row.names")))
  print(f)
  unloadNamespace("fortunes")
}), silent = TRUE)
