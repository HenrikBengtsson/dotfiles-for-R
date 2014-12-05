###########################################################################
# DESCRIPTION:
# This generic .Rprofile file will:
#  (i) Set system environment variables as given in additional
#      .Renviron.<custom> files located in the current working
#      directory ('.') and/or in the home directory ('~').
# (ii) Source additional .Rprofile.<custom> files located in
#      the current working directory ('.') and/or in the home
#      directory ('~').
#
# INSTRUCTIONS:
# 1. Put this .Rprofile in the current working directory ('.'),
#    or in your home directory ('~').  The home directory is
#    given by normalizePath("~").
# 2. Add additional .Renviron.<custom> and .Rprofile.<custom> files,
#    e.g. ~/.Renviron.private and ~/.Rprofile.repos.
#
# AUTHOR: Henrik Bengtsson
# LICENSE: GPL (>= 2.1)
# SOURCE/ISSUES: https://github.com/HenrikBengtsson/dotfiles
###########################################################################
local({

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Startup utility functions
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
log <- function(..., collapse="\n", force=FALSE) {
  args <- commandArgs()
  if (is.element("--slave", args)) return(invisible())
  if (force || Sys.getenv("R_DEBUG") == "TRUE")
    message(paste(..., collapse=collapse))
  invisible()
}

logf <- function(..., collapse="\n", force=FALSE)
  log(sprintf(...), collapse=collapse, force=force)

logp <- function(expr, ...)
  log(utils::capture.output(print(expr)), ...)


log("~/.Rprofile...")

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# (i) Load custom .Renviron.* files, e.g. ~/.Renviron.private
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
local({
  pattern <- "[.]Renviron[.][a-zA-Z0-9]+$"
  files1 <- dir(path=".", pattern=pattern, all.files=TRUE, full.names=FALSE)
  files2 <- dir(path="~", pattern=pattern, all.files=TRUE, full.names=FALSE)
  files2 <- setdiff(files2, files1)
  files <- c(files1, file.path("~", files2))
  for (file in files) {
    logf(" %s...", file)
    readRenviron(file)
    logf(" %s...done", file)
  }
})


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# (ii) Load custom .Rprofile.* files, e.g. ~/.Rprofile.repos
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
local({
  pattern <- "[.]Rprofile[.][a-zA-Z0-9]+$"
  files1 <- dir(path=".", pattern=pattern, all.files=TRUE, full.names=FALSE)
  files2 <- dir(path="~", pattern=pattern, all.files=TRUE, full.names=FALSE)
  files2 <- setdiff(files2, files1)
  files <- c(files1, file.path("~", files2))
  for (file in files) {
    logf(" %s...", file)
    source(file, local=FALSE)
    logf(" %s...done", file)
  }
})


log("~/.Rprofile...done")

}) # local()
