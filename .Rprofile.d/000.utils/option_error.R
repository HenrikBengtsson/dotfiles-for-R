#' @importFrom tools file_path_sans_ext
#' @importFrom utils dump.frames sessionInfo str
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
      file_prefix <- getOption("startup.session.dumpto", "last.dump")
      name <- basename(file_prefix)
      path <- dirname(file_prefix)
      path <- file.path(path, ".Rdump")
      if (!utils::file_test("-d", path)) dir.create(path, showWarnings = FALSE)
      utils::dump.frames(dumpto = name, to.file = FALSE)
      file <- file.path(path, paste0(name, ".rda"))
      print(file)
      save(list = name, envir = .GlobalEnv, file = file)
      
      dumpto <- get(name, envir = .GlobalEnv)
      rm(list = name, envir = .GlobalEnv)
      file <- file.path(path, paste0(name, ".out"))
      sink(file = file)
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
      if (!interactive()) {
        message(sprintf("Troubleshooting information dumped to files: %s.{out,rda}", name))
        message("Execution halted")
        quit("no", status = 1L)
      }
    })
  }
} ## option_error()
