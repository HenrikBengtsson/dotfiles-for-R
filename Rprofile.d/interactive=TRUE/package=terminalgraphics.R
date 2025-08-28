#' Enable terminal graphics, if supported and on SSH
#' 
#' @references
#' [1] https://cran.r-project.org/package=terminalgraphics
if (interactive() &&
    nzchar(Sys.getenv("SSH_CONNECTION")) &&
    requireNamespace("terminalgraphics", quietly = TRUE) &&
    terminalgraphics::has_tgp_support()) {
  options(device = terminalgraphics::tgp)
}
