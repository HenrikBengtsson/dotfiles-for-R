local({
  source("~/repositories/r-ideas/R/find_00lock.R", local = TRUE)
  paths <- unlist(find_00lock(older_than = 3600))
  if (length(paths) > 0) {
    startup_warn("Detected package lock folders that are older than 60 minutes (suggestion they are left overs from failed package installations): [n = %d] %s", length(paths), paste(sprintf("%s [last modified on %s]", sQuote(paths), file.info(paths)$mtime), collapse = ", "))
  }
})

