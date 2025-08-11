#' Sink standard output to standard error in browser
#'
#' EXAMPLE:
#' > foo <- function() browser()
#' > utils::capture.output(foo())
#' Browse[1]> 1+2
#' Browse[1]> supersink()
#' Browse[1]> 1+2
#' [1] 3
#' Browse[1]> c
#' [1] "Called from: browser()" "[1] 3"
#' > 
#' 
#' REFERENCES:
#' * https://github.com/HenrikBengtsson/Wishlist-for-R/issues/90
supersink <- function(envir = parent.frame()) {
  sink(stderr(), split = TRUE)
  do.call(base::on.exit, args = list(expr = quote(sink()), add = TRUE, after = TRUE), envir = envir)
}
