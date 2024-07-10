#' Summarize an Interactive R Session on Shutdown
#'
#' @importFrom startup on_session_exit
if (interactive() && requireNamespace("startup", quietly = TRUE)) {
  gc.time(on = TRUE)
  startup::on_session_exit(local({
    t0 <- Sys.time()
    function(...) {
      dt <- difftime(Sys.time(), t0, units = "auto")
      dt_p <- proc.time()
      names <- c("user", "system", "ellapsed", "user_children", "system_children")
      names(dt_p) <- names
      dt_gc <- structure(gc.time(), class = "difftime", units = "secs", names = names)
      msg <- c(
        "Session summary:",
        sprintf(" * R version: %s", getRversion()),
        sprintf(" * Hostname: %s", Sys.info()[["nodename"]]),
        sprintf(" * Process ID: %d", Sys.getpid()),
        sprintf(" * Garbage collection time: %s (%s)", paste(sprintf("%s=%.2f (%.1f%%)", names(dt_gc), dt_gc, 100 * dt_gc / dt_p), collapse = ", "), attr(dt_gc, "units")),
        sprintf(" * Processing time: %s (secs)", paste(sprintf("%s=%.2f", names(dt_p), dt_p), collapse = ", ")),
        sprintf(" * Wall time: %.2f %s", dt, attr(dt, "units"))
      )
      msg <- paste(msg, collapse = "\n")
      message(msg)
    }
  }))
}
