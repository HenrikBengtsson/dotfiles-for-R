#' Enable terminal graphics, if supported and on SSH
#' 
#' @references
#' [1] https://cran.r-project.org/package=terminalgraphics
if (interactive() && nzchar(Sys.getenv("SSH_CONNECTION")) &&
         requireNamespace("terminalgraphics", quietly = TRUE)) {
  ## Does not work with tmux (< 3.3)         
  tgp_avail <- tryCatch({
    suppressWarnings(terminalgraphics::has_tgp_support())
  }, error = function(e) FALSE)
  if (tgp_avail) options(device = terminalgraphics::tgp)
}
