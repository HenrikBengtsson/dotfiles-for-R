local({
  #' Find 00LOCK-package folders
  #'
  #' @param paths Package library folders to search.
  #'
  #' @param older_than (optional) Keep only package lock folders older than this
  #' as specified either as a [base::POSIXct] timestamp or as the number of
  #' seconds ago.
  #'
  #' @return A named list with identified 00LOCK-package folders.  The names of
  #' the list is `paths`.
  #'
  #' @export
  find_00lock <- function(paths = .libPaths(), older_than = 3600) {
    locks <- lapply(paths, FUN = dir, pattern = "^00LOCK-", full.names = TRUE)
    names(locks) <- paths
  
    if (!is.null(older_than)) {
      stopifnot(length(older_than) == 1L)
      if (is.numeric(older_than)) {
         older_than <- Sys.time() - older_than
      }
      stopifnot(inherits(older_than, "POSIXct"), !is.na(older_than))
      locks <- lapply(locks, FUN = function(paths) {
        if (length(paths) == 0) return(paths)
        paths[file.info(paths)$mtime <= older_than]
      })
    }
  
    locks
  }
  
  paths <- unlist(find_00lock(older_than = 3600))
  if (length(paths) > 0) {
    startup_warn("Detected package lock folders that are older than 60 minutes (suggestion they are left overs from failed package installations): [n = %d] %s", length(paths), paste(sprintf("%s [last modified on %s]", sQuote(paths), file.info(paths)$mtime), collapse = ", "))
  }
})
