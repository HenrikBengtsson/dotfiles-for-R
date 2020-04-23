option_error <- function(what = c("reset", "record_error_msg", "dump")) {
  what <- match.arg(what)

  ## Return dumped frames (instead of dumping them to global env)
  dump_frames <- function() {
    tmpfile <- tempfile(fileext="dump.frames.rda")
    on.exit(file.remove(tmpfile))
    tmpname <- tools::file_path_sans_ext(tmpfile)
    utils::dump.frames(tmpname, to.file=TRUE)
    res <- load(tmpfile)
    dump <- get(res)
  }
  
  if (what == "reset") {
    options(error = NULL)
  } else if (what == "record_error_msg") {
    options(error = function() {
     dumpto <- dump_frames()
     ## The error message (as rendered)
     msg <- attr(dumpto, "error.message")
     assign(".Last.error.message", msg, envir=globalenv()) 
   })
  } else if (what == "dump") {
    options(error = function() {
      tb <- .traceback(NULL)
      if (is.null(tb)) tb <- .traceback(2L)
      name <- getOption("startup.session.dumpto", "last.dump")
      utils::dump.frames(dumpto = name, to.file = FALSE)
      save(list = name, envir = .GlobalEnv, file = paste0(name, ".rda"))
      
      dumpto <- get(name, envir = .GlobalEnv)
      rm(list = name, envir = .GlobalEnv)
      sink(file = paste0(name, ".out"))
      on.exit(sink(NULL))
      
      cat("** System information:\n")
      info <- as.list(Sys.info())
      info$pid <- Sys.getpid()
      info$call <- commandArgs()
      info$pwd <- getwd()
      info$time <- Sys.time()
      utils::str(info, width = 1000L, vec.len = Inf)
    
      cat("\n** Error:\n")
      msg <- attr(dumpto, "error.message")
      cat(msg, "\n", sep = "")
    
      cat("\n** Traceback:\n")
      lapply(seq_along(tb), FUN = function(ii) {
        prefix <- rep("     ", times = length(tb[[ii]]))
        prefix[1] <- sprintf(" %2d: ", ii)
        cat(paste(paste0(prefix, tb[[ii]]), collapse = "\n"), sep = "\n")
      })
    
      cat("\n** Dumped frames:\n")
      print(dumpto)
    
      cat("\n** Session information:\n")
      print(utils::sessionInfo())
    
      ## Call quit(), otherwise R execution will continue
      if (!interactive()) quit("no")
    })
  }
} ## option_error()
