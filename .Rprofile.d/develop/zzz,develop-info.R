## https://github.com/HenrikBengtsson/r-ideas/issues/81
local({
  file <- "DESCRIPTION"
  if (utils::file_test("-f", file)) {
    dcf <- read.dcf(file = file)
    dcf <- as.data.frame(dcf, stringsAsFactors = FALSE)
    pkg <- dcf$Package
    if (length(pkg) == 1L && !is.na(pkg) && nzchar(pkg)) {
      pkg_ver <- dcf$Version
      desc <- suppressWarnings(utils::packageDescription(pkg))
      ver <- NA_character_
      if (is.list(desc)) {
        ver <- sprintf("%s (%s)", desc$Version,
                       dirname(dirname(dirname(attr(desc, "file")))))
      }
      url <- dcf$URL
      if (is.null(url)) url <- NA_character_
      message(sprintf(
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
 - PWD: %s\n",
        pkg, pkg_ver, ver,
	url,
	getRversion(), R.home(),
	Sys.getenv("R_LIBS_USER"),
	paste(sQuote(.libPaths()), collapse=", "),
	{ repos <- getOption("repos"); paste(sprintf("%s=%s", names(repos), sQuote(repos)), collapse=", ") },
	{ envs <- Sys.getenv(); envs <- envs[grep("^_?R_CHECK", names(envs))]; envs <- sprintf("%s=%s", names(envs), envs); envs <- paste(envs, collapse=", "); envs },
	Sys.getenv("CRANCACHE_DIR"),
	getwd()
      ))
    }
  }
})
