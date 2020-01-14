#' Displays summary CRAN packages that you maintain
#'
#' @param MY_CRAN_EMAIL (environment variable) specifying email address of
#'   maintainer of CRAN packages.
#'
#' @param MY_EMAIL (environment variable) alternative used when `MY_CRAN_EMAIL`
#'   is not set/empty.
#'
#' @author Henrik Bengtsson
#'
#' @imports foghorn
try(local({
  email <- Sys.getenv("MY_CRAN_EMAIL", Sys.getenv("MY_EMAIL"))
  if (nzchar(email)) {
    with_nonstrict(foghorn::summary_cran_results(email))
    unloadNamespace("foghorn")
  }
}), silent = TRUE)

