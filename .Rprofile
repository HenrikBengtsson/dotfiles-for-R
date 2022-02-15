# local({
#   for (name in c("R_LIBS_USER", "R_LIBS_SITE")) {
#     path <- Sys.getenv(name)
#     if (nzchar(path) && !utils::file_test("-d", path)) {
#       dir.create(path, showWarnings=FALSE, recursive=TRUE)
#       warning("R needs to be restarted because R package library folder ", name, "=", sQuote(path), " was just created.", immediate. = TRUE)
#     }
#   }
# })

if (!file.exists("~/.Rprofile.skip")) {
  try(BioconductorX::use(unload = TRUE, auto_cleanup = TRUE), silent = TRUE)

  ## See https://cran.r-project.org/package=startup
  tryCatch(startup::startup(all=TRUE), error=function(ex) {
    ## Don't report on errors during 'R CMD'
    if (nzchar(Sys.getenv("R_CMD"))) return()
    message(sprintf(".Rprofile error [%s: %s]: %s", getwd(), paste(commandArgs(), collapse=" "), conditionMessage(ex)))
  })

  ## https://github.com/HenrikBengtsson/rcli
  if (nzchar(Sys.getenv("R_CMD")) && requireNamespace("rcli", quietly=TRUE)) rcli::r_cmd_call()
}
