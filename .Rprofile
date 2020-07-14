## See https://cran.r-project.org/package=startup
tryCatch(startup::startup(all=TRUE), error=function(ex) {
  ## Don't report on errors during 'R CMD'
  if (nzchar(Sys.getenv("R_CMD"))) return()
  message(sprintf(".Rprofile error [%s: %s]: %s", getwd(), paste(commandArgs(), collapse=" "), conditionMessage(ex)))
})

## https://github.com/HenrikBengtsson/rcli
if (nzchar(Sys.getenv("R_CMD")) && requireNamespace("rcli", quietly=TRUE)) rcli::r_cmd_call()
