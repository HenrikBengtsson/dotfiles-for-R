if (.Platform$OS.type == "windows") {
  ## Make browseURL() on files works in more cases (also via Rscript)
  options(browser=function(...) R.utils::shell.exec2(...))

  ## Wine on Linux tweaks
  if (getOption("R_WINE", "FALSE") == "TRUE") {
    options(download.file.method = "libcurl")
    Sys.setenv(LC_TIME = "C")
    Sys.setenv(LC_MONETARY = "C")
    options(useFancyQuotes = FALSE)
  }

  ## Use new gcc-4.9.3 toolchain in R (>= 3.3.0) for Windows
  ## (source: Bioconductor https://goo.gl/MMbGkg)
  ## NOTE: This only works if `--no-init-file` is _not_ used.
  if (getRversion() >= "3.3.0" && !nzchar(Sys.getenv("BINPREF"))) {
    local({
      ## Find out how R was built
      ## https://twitter.com/opencpu/status/717411491364798464
      Rbin <- file.path(R.home("bin"), "R")
      cby <- suppressWarnings(system2(Rbin, "--vanilla CMD config COMPILED_BY",
                                      stdout = TRUE, stderr = TRUE))
      if (any(cby %in% c("gcc-4.9.3"))) {
        path <- "C:/Rtools/mingw_$(WIN)/bin/"
        message(sprintf("NOTE: Setting BINPREF=%s (via .Rprofile)", path))
        Sys.setenv(BINPREF = path)
      }
    })
  }
}
