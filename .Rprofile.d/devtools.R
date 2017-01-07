## For devtools::revdep()
if (is.null(getOption("devtools.revdep.libpath"))) {
  local({
    p <- file.path(dirname(.libPaths()[[1]]), "devtools", getRversion()[1,1:2])
    dir.create(p, recursive=TRUE, showWarnings=FALSE)
    options(devtools.revdep.libpath=p)
  })
}

