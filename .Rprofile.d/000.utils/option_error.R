option_error <- function(what = c("reset", "dump")) {
  what <- match.arg(what)
  
  if (what == "reset") {
    options(error = NULL)
  } else {
    options(error = function() {
      tb <- .traceback(2L)
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
