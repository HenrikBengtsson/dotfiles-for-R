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
 - CRAN: %d days (>= 7 days) since last update, %d updates (<= 6) in 180 days (days to-go: %s)\
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

  now <- Sys.time()
  path <- tools::R_user_dir("startup", which = "cache")
  file <- file.path(path, "cran-archive-db.rds")
  mtime <- file.info(file)[["mtime"]]
  if (!is.na(mtime) && difftime(now, mtime, units = "hours") < 12.0) {
    archive_db <- tryCatch(readRDS(file), error = function(e) NULL)
  } else {
    archive_db <- NULL
  }
  if (is.null(archive_db)) {
    archive_db <- if (getRversion() >= "4.5.0") tools::CRAN_archive_db() else tools:::CRAN_archive_db()
    saveRDS(archive_db, file = file)
  }
  
  file <- file.path(path, "cran-current-db.rds")
  mtime <- file.info(file)[["mtime"]]
  if (!is.na(mtime) && difftime(now, mtime, units = "hours") < 12.0) {
    current_db <- tryCatch(readRDS(file), error = function(e) NULL)
  } else {
    current_db <- NULL
  }
  if (is.null(current_db)) {
    current_db <- if (getRversion() >= "4.5.0") tools::CRAN_current_db() else tools:::CRAN_current_db()
    saveRDS(current_db, file = file)
  }
  mtimes <- c(current_db[match(pkg, sub("_.*", "", rownames(current_db)), nomatch = 0L), "mtime"], archive_db[[pkg]]$mtime)
  deltas <- Sys.Date() - as.Date(sort(mtimes, decreasing = TRUE))
  ## Number of days since last update
  recency <- as.numeric(deltas[1L])
  ## Number of updates in the last 180 days
  frequency <- sum(deltas <= 180)
  deltas <- 180 - deltas
  if (length(deltas) > frequency + 2) deltas <- deltas[1:(frequency+2)]
  
  gha_files <- if (utils::file_test("-d", ".github/workflows")) {
    dir(path = ".github/workflows", pattern = "[.](yml|yaml)$", full.names = TRUE)
  } else { character(0L) }

  message(sprintf(fmtstr,   
    pkg, pkg_ver, ver,
    recency, frequency, paste(deltas, collapse = ", "),
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
    "actions/cache@v4",
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
