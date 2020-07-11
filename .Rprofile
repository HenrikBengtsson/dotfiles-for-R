## See https://cran.r-project.org/package=startup
tryCatch(startup::startup(all=TRUE), error=function(ex) {
  ## Don't report on errors during 'R CMD'
  if (nzchar(Sys.getenv("R_CMD"))) return()
  message(sprintf(".Rprofile error [%s: %s]: %s", getwd(), paste(commandArgs(), collapse=" "), conditionMessage(ex)))
})
if (nzchar(Sys.getenv("R_CMD")) && requireNamespace("rcli", quietly=TRUE)) rcli::r_cmd_call()


if (Sys.getenv("RSTUDIO") == "1" && !nzchar(Sys.getenv("RSTUDIO_TERM"))) {
  invisible(trace(parallel:::mcfork, tracer = quote(warning("parallel::mcfork() was used. Note that forked processes, e.g. parallel::mclapply(), may be unstable when used from the RStudio Console [https://github.com/rstudio/rstudio/issues/2597#issuecomment-482187011]", call.=FALSE))))
}

