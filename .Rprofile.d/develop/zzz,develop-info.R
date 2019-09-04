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
      message(sprintf("Package folder:\n - package: %s\n - devel version: %s\n - installed version: %s\n - URL: %s\n - R version: %s (%s)\n - R_LIBS_USER: %s\n - CRANCACHE_DIR: %s\n - PWD: %s\n", pkg, pkg_ver, ver, url, getRversion(), R.home(), Sys.getenv("R_LIBS_USER"), Sys.getenv("CRANCACHE_DIR"), getwd()))
    }
  }
})
