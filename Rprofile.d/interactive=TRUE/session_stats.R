#' Summarize an Interactive R Session on Shutdown
#'
#' @importFrom startup on_session_exit
if (interactive() && requireNamespace("startup")) {
  startup::on_session_exit(local({
    t0 <- Sys.time()
    function(...) {
      dt <- difftime(Sys.time(), t0, units = "auto")
      msg <- c(
        "Session summary:",
        sprintf(" * R version: %s", getRversion()),
        sprintf(" * Hostname: %s", Sys.info()[["nodename"]]),
        sprintf(" * Process ID: %d", Sys.getpid()),
        sprintf(" * Wall time: %.2f %s", dt, attr(dt, "units"))
      )
      msg <- paste(msg, collapse = "\n")
      message(msg)
    }
  }))
}
