#' Install Packages for a Specific CRAN Task View
#'
#' @param view A CRAN Task View of <https://cran.r-project.org/web/views/>.
#'
#' @param repos The CRAN repository URL.
#'
#' @return
#' A vector of package names.
#'
#' @importFrom ctv::ctv
ctv_install_packages <- function(view, repos = getOption("repos")[["CRAN"]], ...) {
  pkgs <- ctv::ctv(view, repos = repos)$packagelist$name
  stopifnot(length(pkgs) > 0)
  todo <- setdiff(pkgs, installed.packages()[,"Package"])
  install.packages(todo, ...)
  invisible(pkgs)
}
