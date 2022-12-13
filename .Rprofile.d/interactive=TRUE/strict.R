#' Produce warnings when partial name matching has been used
#'
#' Options that are set:
#' * `warnPartialMatchDollar`
#' * `warnPartialMatchArgs`
#' * `warnPartialMatchAttr`
#' * `showWarnCalls`
#'
#' @author Henrik Bengtsson
options(
  warnPartialMatchDollar = TRUE,
  warnPartialMatchArgs   = TRUE,
  warnPartialMatchAttr   = TRUE,
  showWarnCalls          = TRUE  ## show call stack for warnings
)
