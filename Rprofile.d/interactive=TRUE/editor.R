#'
local({
  editor <- getOption("editor")
  
  ## Not set?
  if (!is.character(editor)) return()

  ## No command-line options specified?
  if (!grepl("[[:space:]]+", editor)) return()

  ## Turn into an R function, if there are command-line options
  ## to avoid file.edit("README.md") => sh: 1: emacs -nw: not found
  editor_fcn <- function(file, title = file) {
    system(sprintf("%s %s", editor, shQuote(file)))
  }
  options(editor = editor_fcn)
})
