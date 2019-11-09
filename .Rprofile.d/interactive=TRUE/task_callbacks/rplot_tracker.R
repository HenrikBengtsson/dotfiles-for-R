#' Alert about newly produced Rplots*.pdf files
#'
#' Look for newly produced `Rplots*.pdf` files, which may be produced
#' when running in batch mode or when screen devices are not available.
#' See `?options` and option `'device'`.
#'
#' @author Henrik Bengtsson
#'
#' @import startup utils

startup_toolbox({
rplots_tracker <- local({
  prev_files <- NULL

  message <- function(msg, ...) {
    msg <- sprintf("NOTE: %s", msg)
    if (requireNamespace("crayon", quietly=TRUE))
      msg <- crayon::blurred(msg)
    base::message(msg, ...)
  }

  function(...) {
    files <- dir(pattern = "Rplots[0-9]*.pdf$")
    if (length(files) == 0) return(TRUE)
    files <- files[utils::file_test("-f", files)]
    if (length(files) == 0) return(TRUE)

    ## Setup?
    if (is.null(prev_files)) {
      info <- lapply(files, FUN = file.info)
      names(info) <- files
      prev_files <<- info
      return(TRUE)
    }
    
    ## Any files dropped?
    if (length(prev_files) > 0) {
      dropped <- setdiff(names(prev_files), files)
      if (length(dropped) > 0) {
              message("Graphics files removed: ",
	        paste(sQuote(dropped), collapse = ", "))
        prev_files <<- prev_files[files]
      }
    }
    
    for (kk in seq_along(files)) {
      file <- files[kk]
      info <- file.info(file)
      if (file %in% names(prev_files)) {
        prev_file <- prev_files[[file]]
	if (!identical(info$size, prev_file$size)) {
	  why <- sprintf(" (file size %d -> %d bytes)",
	                 prev_file$size, info$size)
          message(sprintf("Graphics file modified%s: %s", why, sQuote(file)))
	} else if (!identical(info$mtime, prev_file$mtime)) {
	  why <- sprintf(" (mtime %s -> %s)", prev_file$mtime, info$mtime)
          message(sprintf("Graphics file modified%s: %s", why, sQuote(file)))
	}
      } else {
        message(sprintf("Graphics file added: %s", sQuote(file)))
        prev_files[file] <- info
      }
    }

    TRUE
  }
})
})

invisible(addTaskCallback(rplots_tracker, name = "Rplots tracker"))
