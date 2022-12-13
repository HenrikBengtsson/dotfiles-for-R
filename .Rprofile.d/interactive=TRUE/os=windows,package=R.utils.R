#' Tweaks for a smoother R experience on MS Windows
#'
#' Options that are set:
#' * `browser`
#'
#' @author Henrik Bengtsson
#' @imports R.utils

## Make browseURL() on files works in more cases (also via Rscript)
options(browser = function(...) R.utils::shell.exec2(...))
