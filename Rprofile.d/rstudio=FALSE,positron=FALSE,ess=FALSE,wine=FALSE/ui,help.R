## Open file:// in Chrome, everything else in system default browser
options(browser = function(url) {
  is_uri <- grepl("^[[:alpha:]]+://", url, ignore.case = TRUE)
  is_file_uri <- grepl("^file://", url, ignore.case = TRUE)
  is_html_file <- grepl("[.](htm|html)$", url, ignore.case = TRUE)

  ## Special case: Firefox does not allow to open local HTML files
  if (is_html_file && (!is_uri || is_file_uri)) {
    bin <- Sys.which("google-chrome")
    if (!nzchar(bin)) stop("Please install google-chrome")
  } else {
    bin <- Sys.which("xdg-open")
    if (!nzchar(bin)) stop("Please install xdg-open")
  }
  browseURL(url, browser = bin)
})
