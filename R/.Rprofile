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
# Startup utility functions
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

startupApply <- function(prefix, FUN, ...) {
  ol <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", ol))
  Sys.setlocale("LC_COLLATE", "C")
  pattern <- sprintf("%s[.][-_a-zA-Z0-9]+$", prefix)
  files1 <- dir(path=".", pattern=pattern, all.files=TRUE, full.names=FALSE)
  files2 <- dir(path="~", pattern=pattern, all.files=TRUE, full.names=FALSE)
  files2 <- setdiff(files2, files1)
  files <- c(files1, file.path("~", files2))
  for (file in files) {
    logf(" %s...", file)
    FUN(file, ...)
    logf(" %s...done", file)
  }
}

log("~/.Rprofile...")

# (i) Load custom .Renviron.* files, e.g. ~/.Renviron.private
if (exists("readRenviron", envir=baseenv(), mode="function")) {
  startupApply("[.]Renviron", FUN=readRenviron)
}

# (ii) Load custom .Rprofile.* files, e.g. ~/.Rprofile.repos
startupApply("[.]Rprofile", FUN=source)

# (iii) Check for common mistakes?
if (isTRUE(getOption(".Rprofile-check", TRUE))) {
  if (isTRUE(getOption(".Rprofile-check-encoding", TRUE) && !interactive() && getOption("encoding", "native.enc") != "native.enc")) {
    msg <- (sprintf("POTENTIAL PROBLEM: Option 'encoding' seems to have been set (to '%s') during startup, cf. Startup.  Changing this from the default 'native.enc' is known to have caused problems, particularly in non-interactive sessions, e.g. installation of some packages fails. To disable this warning, set option '.Rprofile-check-encoding' to FALSE, or set the encoding conditionally, e.g. if (interactive()) options(encoding='UTF-8').",  getOption("encoding")))
    warning(msg)
  }
}

log("~/.Rprofile...done")

}) # local()
