local({
  width <- suppressWarnings(try(
    system2("tput", args = "cols", stdout = TRUE)
  , silent = TRUE))
  width <- as.integer(width)
  if (length(width) == 0 || !is.finite(width))
    width <- Sys.getenv("COLUMNS")
  width <- as.integer(width)
  if (length(width) == 1 && !is.na(width)) options(width = width)
})
