## See https://cran.r-project.org/package=startup
tryCatch(startup::startup(all=TRUE), error=function(ex) {
  args <- commandArgs()
  nargs <- length(args)
  pwd <- getwd()
  if (nargs >= 3L) {
    is_R <- (basename(args[1]) == "R")
    ## Don't report when running 'R CMD INSTALL'
    if (nargs == 3L && is_R && args[nargs-1] == "--no-save" && args[nargs] == "--slave" && grepl("/Rtmp.*/R.INSTALL.*/", pwd)) return()
    ## Don't report when running 'R CMD check'
    if (any(grepl(".RchecknextArg", args))) return()
  }
  message(sprintf(".Rprofile error [%s: %s]: %s", getwd(), paste(commandArgs(), collapse=" "), conditionMessage(ex)))
})

