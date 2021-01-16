#' @imports prettycode
#' @imports utils
print.function <- local({
    ## https://cran.r-project.org/web/packages/prettycode
    if (requireNamespace("prettycode", quietly = TRUE)) {
        print_function <- prettycode:::print.function
    } else {
        print_function <- base::print.function
    }
    
    function(x, useSource = TRUE, ...) {
        print_function(x, useSource=useSource, ...)
        pathname <- utils::getSrcFilename(x, full.names = TRUE)
        pathname <- pathname[nzchar(pathname)]
        if (length(pathname) > 0L) {
            info <- sQuote(pathname[1])
            first <- utils::getSrcLocation(x, which = "line", first = TRUE)
            if (!is.null(first)) {
                last <- utils::getSrcLocation(x, which = "line", first = FALSE)
                range <- unique(c(first, last))
                if (last == first) {
                    info <- sprintf("%s (line %d)", info, first)
                } else {
                    info <- sprintf("%s (lines %d:%d)", info, first, last)
                }
            }
            cat(sprintf("<srcfile: %s>\n", info))
        }
        invisible(x)
    }
})
