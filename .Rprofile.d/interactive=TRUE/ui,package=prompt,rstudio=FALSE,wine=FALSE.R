## Package: prompt
## https://github.com/gaborcsardi/prompt
## install.packages("memuse")
## source("http://callr.org/install#gaborcsardi/prompt")
## Required packages: memuse

if (!exists("toggle", mode = "function", envir = getNamespace("prompt"))) {
  use_prompt <- local({
    env <- prompt:::prompt_env
    env$default_prompt <- getOption("prompt", "> ")
    env$disabled_prompt <- env$prompt
    env$enabled <- TRUE

    function(enable = TRUE) {
      ## Toggle?
      if (is.na(enable)) {
        enable <- !env$enabled
      } else if (enable == env$enabled) {
        ## Nothing do to?
        return(invisible(FALSE))
      }

      if (enable) {
        prompt::set_prompt(env$disabled_prompt)
      } else {
        env$disabled_prompt <- env$prompt
        prompt::set_prompt(env$default_prompt)
      }

      env$enabled <- enable

      invisible(TRUE)
    }
  })
  
  toggle_prompt <- function() use_prompt(enable = NA)
}

startup_toolbox({
  last_value <- local({
    db <- list()

    MAX_STACK_SIZE <- 10L

    function(value = 0L, action = c("get", "set", "list")) {
        action <- match.arg(action)
        if (action == "get" && identical(value, "list")) action <- "list"
        if (action == "get") {
            pos <- as.integer(value)
            n <- length(db)
            if (n == 0) {
                warning("last_value() stack is empty.")
            } else if (pos == 0L) {
                return(db[[n]])
            } else if (-n <= pos && pos < 0L) {
                return(db[[-pos]])
            } else {
                warning(sprintf("last_value() out of range [-%d, 0]: %d", n, pos))
            }
        } else if (action == "list") {
            db
        } else if (action == "set") {
            t <- c(list(value), db)
            if (length(t) > MAX_STACK_SIZE) t <- t[seq_len(MAX_STACK_SIZE)]
            db <<- t
        }
    }
})
})


prompt::set_prompt(local({
  symbol <- clisymbols::symbol
  blue <- function(x) if (is.null(x)) NULL else crayon::blue(x)
  silver <- function(x) if (is.null(x)) NULL else crayon::silver(x)
  green <- function(x) if (is.null(x)) NULL else crayon::green(x)
  yellow <- function(x) if (is.null(x)) NULL else crayon::yellow(x)
  red <- function(x) if (is.null(x)) NULL else crayon::red(x)

  ## WORKAROUND: https://github.com/gaborcsardi/crayon/issues/48
  if (crayon:::has_color()) options(crayon.enabled = TRUE)

  get_width <- function() {
    ## Identify best way to infer dynamic `width`, iff at all
    get_width <<- function() as.integer(Sys.getenv("COLUMNS"))
    if (is.na(get_width())) {
      get_width <<- function() {
        as.integer(try(system2("tput", args = "cols", stdout = TRUE), silent = TRUE))
      }	
    }
    if (is.na(get_width())) get_width <<- function() NA_integer_
    get_width()
  }

  has_git <- function() {
    !inherits(try(prompt:::check_git_path(), silent = TRUE), "try-error")
  }

  status <- function(ok) {
    if (ok) green(symbol$tick) else red(symbol$cross)
  }
  
  mem <- function() {
    silver(prompt:::memory_usage())
  }

  pkg <- function() {
    if (!prompt:::using_devtools()) return(NULL)
    blue(prompt:::devtools_package())
  }
    
  gitinfo <- function() {
    if (!has_git()) return(NULL)
    info <- prompt:::git_info()
    if (nchar(info) == 0) return(NULL)
    silver(info)
  }

  ## Report on active sinks
  sinks <- function() {
    n_out <- sink.number(type = "output")
    n_msg <- sink.number(type = "message") - 2L
    if (n_out == 0 && n_msg == 0) return(NULL)
    if (n_out > 0 && n_msg == 0) return(yellow(sprintf("%d output sink", n_out)))
    if (n_out == 0 && n_msg > 0) return(red(sprintf("%d message sink", n_msg)))
    red(sprintf("%d output & %d message sink", n_out, n_msg))
  }

  ## Report on open graphics devices
  devs <- function() {
    devs <- grDevices::dev.list()
    n_devs <- length(devs)
    if (n_devs == 0) return(NULL)
    devs <- sort(unique(names(devs)))
    if (n_devs == 1) {
      msg <- sprintf("%d graphics device (%s)", n_devs, devs)
      return(yellow(msg))
    }
    msg <- sprintf("%d graphics devices (%s)", n_devs,
                   paste(devs, collapse = ", "))
    red(msg)
  }
  
  profmem_prompt <- local({
    .suspended <- getOption("profmem.prompt.suspend", TRUE)
    .depth <- NULL
    .last_profmem <- NULL
  
    ## TODO:
    ## * Allow user change threshold of the profmem prompt
    ## * Allow user to suspend/resume the profmem prompt
    ## * Add support for custom prompt(profmem, depth, ...) function
    ## * Have built-in prompt() function return args as attributes
    function(what = c("update", "suspend", "resume", "prompt", "begin", "end"), threshold = 10 * 1024) {
      what <- match.arg(what)
  
      ## Produce prompt string
      if (what == "prompt") {
        if (is.null(.last_profmem)) return("")
  
        depth <- profmem::profmem_depth()
        if (!is.null(.depth) && .depth != depth) {
          return("waiting for active profmem to close")
        }
        
        ## Don't report on 'new page' entries
        pm <- subset(.last_profmem, what != "new page")
        threshold <- attr(pm, "threshold")
        threshold <- structure(threshold, class = "object_size")
        threshold <- format(threshold, units = "auto", standard = "IEC")
        
        n <- nrow(pm)
        if (n == 0) {
          prompt <- sprintf("0 %s+ alloc", threshold)
        } else {
          total <- profmem::total(pm)
          total <- structure(total, class = "object_size")
          total <- format(total, units = "auto", standard = "IEC")
          prompt <- sprintf("%s in %d %s+ alloc",
                            total, n, threshold)
        }
      
        return(prompt)
      }
  
      
      ## Begin and end profiling by the prompt
      if (what == "begin") {
        if (!.suspended && is.null(.depth)) {
          tryCatch({
            profmem::profmem_begin(threshold = threshold)
            .depth <<- profmem::profmem_depth()
          }, error = function(ex) NULL)
        }
      } else if (what == "end") {
        if (!is.null(.depth) && .depth == profmem::profmem_depth()) {
          .last_profmem <<- tryCatch({
            p <- profmem::profmem_end()
            .depth <<- NULL
            p
          }, error = function(ex) NULL)
        }
      }
  
  
      ## Tweak how profiling is done by the prompt
      if (what == "suspend") {
        .suspended <<- TRUE
        force(t <- .suspended)
      } else if (what == "suspend") {
        .suspended <<- FALSE
        force(t <- .suspended)
      } else if (what == "update") {
      }
      
    }
  })

  alloc <- function() {
    if (getOption("profmem.suspend", FALSE)) {
      prompt <- "profmem suspended"
    } else {
      prompt <- profmem_prompt("prompt")
    }
    if (nzchar(prompt)) prompt <- sprintf("(%s)", prompt)
    silver(prompt)
  }
  
  #' @param expr The expression evaluated
  #' @param value The value of the expression
  #' @param ok Whether the evaluation succeeded or not
  #' @param visible Whether the value is visible or not
  prompt_fancy_hb <- function(expr, value, ok, visible) {
#    message("expr: ", deparse(expr))
#    message("value: ", value)
#    message("ok: ", ok)
#    message("visible: ", visible)
    info <- list(
      status = status(ok),
      mem = mem(),
      alloc = alloc(),
      pkg = pkg(),
      gitinfo = gitinfo(),
      devs = devs(),
      sinks = sinks()
    )
    paste0("\n", paste(unlist(info), collapse = " "), "\n> ")
  }

  ## In case last_value() becomes deleted
  .last_value <- last_value
  
  function(...) {
    .last_profmem <<- profmem_prompt("end")
    if (!getOption("profmem.suspend", FALSE)) {
      on.exit({
        profmem_prompt("begin", threshold = 10 * 1024)
      })
    }
    
    value <- .Last.value
    
    ## In case last_value() has been deleted
    if (!exists("last_value", mode = "function")) last_value <<- .last_value
      
    last_value(value, action = "set")

    ## Dynamically set option 'width'
    if (!is.na(width <- get_width())) options(width = width)

    ## prompt_fancy() requires 'git'
    prompt_fancy_hb(...)
  }
}))
