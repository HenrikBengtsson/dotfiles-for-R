#' Configure R's HTML help-page server
#'
#' Options that are set:
#' * `help.ports`
#' * `help_type`
#' * `browser`
#'
#' @author Henrik Bengtsson
#'
#' @imports tools

## Setup built-in HTTP daemon
## Always serve HTML help on the same port for a given version of R
local({
  port <- sum(c(1e4, 100) * as.double(R.version[c("major", "minor")]))
  options(help.ports = port + 0:9)
})

## Try to start HTML help server
suppressMessages(try(tools::startDynamicHelp()))

options(help_type = "html")


## Open file:// in Chrome, everything else in system default browser
options(browser = function(url) {
  is_uri <- grepl("^[[:alpha:]]+://", url, ignore.case = TRUE)
  is_file_uri <- grepl("^file://", url, ignore.case = TRUE)
  is_html_file <- grepl("[.](htm|html)$", url, ignore.case = TRUE)

  ## Special case: Firefox does not allow to open local HTML files
  if (is_html_file && (!is_url || is_file_uri)) {
    bin <- Sys.which("google-chrome")
    if (!nzchar(bin)) stop("Please install google-chrome")
  } else {
    bin <- Sys.which("xdg-open")
    if (!nzchar(bin)) stop("Please install xdg-open")
  }
  browseURL(url, browser = bin)
})

