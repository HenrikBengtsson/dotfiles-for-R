# Use regular single quotes
options(useFancyQuotes=FALSE)

## Use a local R.cache root directory on each compute node
if (grepl("^n[0-9]+$", Sys.getenv("HOST"))) {
  options("R.cache::rootPath"=sprintf("/scratch/%s/.Rcache", Sys.getenv("USER")))
}

## Enable parallel processing for R.filesets::dsApply()
options("R.filesets/parallel"="BiocParallel::BatchJobs")

## ROBUSTNESS: Enable strict full-names translator checks
options("R.filesets::onRemapping"="error")

## Quick access to system calls
if (interactive()) {
  attach(name="CBC tools", list(
    print.bang = function(x, ...) x(...),
    qstat = structure(function() system("qstat"), class="bang"),
    qme = structure(function() system("qme"), class="bang")
  ))
}

