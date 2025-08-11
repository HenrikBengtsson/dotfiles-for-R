#' Circumvent standard output being sink:ed when debugging with browser
#' 
#' @examples interactive()
#' test <- function() browser()
#' out <- utils::capture.output(test())
#' #> Browse[1]> 1+2
#' #> Browse[1]> supersink()
#' #> Browse[1]> 1+2
#' #> [1] 3
#' #> Browse[1]> c
#' > 
#' 
#' @authors
#' Henrik Bengtsson, Lionel Henry, Tomasz Kalinowski (R Dev Day; useR! 2025)
#' 
#' @references
#' * <https://github.com/HenrikBengtsson/Wishlist-for-R/issues/90>
#' 
#' @export
supersink <- function() {
  base::sink(base::getConnection(1), type = "output", split = TRUE)
  base::do.call(base::on.exit, args = list(
    expr = base::quote(sink()),
    add = TRUE,
    after = TRUE
  ), envir = base::parent.frame())
}
