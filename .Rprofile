## RStudio Console does not support setup_strategy="parallel" on macOS
## RStudio already avoids this for the 'parallel' package when loaded.
## Until parallelly (>= 1.26.1) is available, which will be agile to
## whatever RStudio sets, we have to disable it ourselved. The following
## will do this automagically when 'parallelly' is loaded and only if
## needed, e.g. it will _not_ disable when running R in the terminal.
setHook(packageEvent("parallelly", "onLoad"), function(pkgname, pkgpath) {
  if (Sys.getenv("RSTUDIO") == "1" && !nzchar(Sys.getenv("RSTUDIO_TERM")) &&
      Sys.info()[["sysname"]] == "Darwin" &&
      packageVersion("parallelly") <= "1.26.0") {
    options(parallelly.makeNodePSOCK.setup_strategy = "sequential")
  }
})


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
