#' Summarize an Interactive R Session on Shutdown
#'
#' @importFrom startup on_session_exit
if (interactive() && requireNamespace("startup", quietly = TRUE)) {
  gc.time(on = TRUE)
  startup::on_session_exit(local({
    t0 <- Sys.time()

    difftime2txt <- function(x) {
      txt <- structure(character(length(x)), names = names(x))
      for (name in names(x)) {
        dt <- x[[name]]
        unit <- "secs"
        if (dt >= 3600L) {
          unit <- "hours"
          dt <- dt / 3600L
        } else if (dt >= 60L) {
          unit <- "mins"
          dt <- dt / 60L
        }
        txt[name] <- sprintf("%.2f %s", dt, unit)
      }
      txt
    }
    
    function(...) {
      dt_w <- difftime(Sys.time(), t0, units = "auto")
      dt_p <- structure(proc.time(), class = "difftime", units = "secs", names = c("user", "system", "ellapsed", "user_children", "system_children"))
      dt_gc <- structure(gc.time(), class = "difftime", units = "secs", names = names(dt_p))

      dt_p_txt <- difftime2txt(dt_p)
      dt_gc_txt <- difftime2txt(dt_gc)

      msg <- c(
        "Session summary:",
        sprintf(" * R version: %s", getRversion()),
        sprintf(" * Hostname: %s", Sys.info()[["nodename"]]),
        sprintf(" * Process ID: %d", Sys.getpid()),
        sprintf(" * Garbage collection time: %s", paste(sprintf("%s=%s (%.1f%%)", names(dt_gc_txt), dt_gc_txt, 100 * dt_gc / as.numeric(dt_p)), collapse = ", ")),
        sprintf(" * Processing time: %s", paste(sprintf("%s=%s (%.1f%%)", names(dt_p_txt), dt_p_txt, 100 * as.numeric(dt_p) / as.numeric(dt_p[["ellapsed"]])), collapse = ", ")),
        sprintf(" * Wall time: %.2f %s", dt_w, attr(dt_w, "units"))
      )
      msg <- paste(msg, collapse = "\n")
      message(msg)
    }
  }))
}
