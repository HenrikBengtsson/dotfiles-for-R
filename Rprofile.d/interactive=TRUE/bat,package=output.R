#' @importFrom output capture_output
bat <- function(..., args = c("--language=r")) {
  print(...) |> output::capture_output() |> system2("bat", args = args, input=_)
}
