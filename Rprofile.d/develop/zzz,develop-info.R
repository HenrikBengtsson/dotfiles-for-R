#' @seealso
#' https://github.com/HenrikBengtsson/r-ideas/issues/81
#'
#' @imports utils
local({
  cmdArgs <- commandArgs()
  # Skip?
  if (!interactive() || length(cmdArgs) > 1L) return(invisible())
  
  file <- "DESCRIPTION"
  if (!utils::file_test("-f", file)) return(invisible())

  dcf <- read.dcf(file = file)
  dcf <- as.data.frame(dcf, stringsAsFactors = FALSE)
  pkg <- dcf$Package
  
  if (length(pkg) != 1L || is.na(pkg) || !nzchar(pkg)) return(invisible())
  
  pkg_ver <- dcf$Version
  desc <- suppressWarnings(utils::packageDescription(pkg))
  ver <- NA_character_
  if (is.list(desc)) {
    ver <- sprintf("%s (%s)", desc$Version,
                   dirname(dirname(dirname(attr(desc, "file")))))
  }
  url <- dcf$URL
  if (is.null(url)) url <- NA_character_
  fmtstr <- {
"Package folder:\
 - package: %s\
 - devel version: %s\
 - installed version: %s\
 - URL: %s
 - R version: %s (%s)\
 - R_LIBS_USER: %s\
 - .libPaths(): %s\
 - repos: %s\
 - R check env vars: %s\
 - CRANCACHE_DIR: %s\
 - PWD: %s\
 - commandArgs(): %s\
 - .github/workflows/: %s\n"
  }

  gha_files <- if (utils::file_test("-d", ".github/workflows")) {
    dir(path = ".github/workflows", pattern = "[.](yml|yaml)$", full.names = TRUE)
  }

  message(sprintf(fmtstr,   
    pkg, pkg_ver, ver,
    url,
    getRversion(), R.home(),
    Sys.getenv("R_LIBS_USER"),
    paste(sQuote(.libPaths()), collapse=", "),
    { repos <- getOption("repos"); paste(sprintf("%s=%s", names(repos), sQuote(repos)), collapse=", ") },
    { envs <- Sys.getenv(); envs <- envs[grep("(^_?R_CHECK)", names(envs))]; envs <- sprintf("%s=%s", names(envs), envs); envs <- paste(envs, collapse=", "); envs },
    Sys.getenv("CRANCACHE_DIR"),
    getwd(),
    paste(sQuote(cmdArgs), collapse = " "),
    paste(basename(gha_files), collapse = ", ")
  ))

  actions <- c(
    ## GitHub
    "actions/checkout@v4",
    "actions/upload-artifact@v4",
    ## r-lib
    "r-lib/actions/setup-pandoc@v2",
    "r-lib/actions/setup-r@v2",
    "r-lib/actions/setup-r-dependencies@v2",
    ## r-hub
    "r-hub/actions/setup@v1",
    "r-hub/actions/checkout@v1",
    "r-hub/actions/setup-r@v1"
  )
  ## Validate GitHub Action files
  for (file in gha_files) {
    old <- NULL
    bfr <- readLines(file, warn = FALSE)
    
    ## Any outdated actions?
    for (action in actions) {
      version <- sub(".*@", "", action)
      action <- sub("@.*", "", action)
      pattern <- sprintf(".*[[:space:]](%s)@(v[[:digit:]]+).*", action)
      lines <- grep(pattern, bfr, value = TRUE)
      if (length(lines) > 0) {
        v <- sub(pattern, "\\2", lines)
        v <- v[(v != version)]
        if (length(v) > 0) old <- c(old, sprintf("%s@%s", action, v))
      }
    }
    if (length(old) > 0) {
      warning(sprintf("%s uses outdated actions: [n=%d] %s\n", file, length(old), paste(old, collapse = ", ")), immediate. = TRUE, call. = FALSE)
    }

    ## Any outdated R versions?
    old <- grep("r: '3[.][0-5]'", bfr, value = TRUE)
    if (length(old) > 0) {
      warning(sprintf("%s uses outdated R versions: [n=%d] %s\n", file, length(old), paste(old, collapse = ", ")), immediate. = TRUE, call. = FALSE)
    }
  }

  ## For conviency:
  assign(".packageName", pkg, envir = globalenv())
})
