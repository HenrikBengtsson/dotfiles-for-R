#' Configure R's HTML help-page server
#'
#' Options that are set:
#' * `help.ports`
#' * `help_type`
#' * `browser`
#'
#' @author Henrik Bengtsson
#'
#' @import tools

## Setup built-in HTTP daemon
## Always only the HTML help on the same port
local({
  port <- sum(c(1e4, 100) * as.double(R.version[c("major", "minor")]))
  options(help.ports = port + 0:9)
})

## Try to start HTML help server
suppressMessages(try(tools::startDynamicHelp()))

options(help_type = "html")

if (nzchar(Sys.which("xdg-open"))) options(browser="xdg-open")
