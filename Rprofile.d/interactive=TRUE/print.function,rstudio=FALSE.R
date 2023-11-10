#' Print Functions with Additional Source Information
#'
#' @param x A [base::function]
#'
#' @param useSource Passed to [base::print.function] as-is.
#'
#' @param \dots Not used.
#'
#' @return (invisible) the function `x`.
#'
#' @details
#' If \pkg{prettycode} is installed, then `prettyprint:::print.function()`
#' is used to print the function instead of [base::print.function].
#' To disable it, set R option `cli.num_colors=1` or environment
#' variable `NO_COLOR=false`.
#'
#' If \pkg{globals} is installed, then objects that are used by function
#' `x` and that live in other namespaces (packages) are listed as a
#' **roxygen2** `@importFrom` comment.
#'
#' @imports prettycode
#' @importFrom utils getSrcFilename getSrcLocation
#' @importFrom globals globalsOf cleanup
print.function <- local({
    ## https://cran.r-project.org/web/packages/prettycode
    if (requireNamespace("prettycode", quietly = TRUE)) {
        print_function <- prettycode:::print.function
    } else {
        print_function <- base::print.function
    }
    
    function(x, useSource = TRUE, ...) {
        if (requireNamespace("globals", quietly = TRUE)) {
            envir <- environment(x)
            globals <- globals::globalsOf(x, envir = envir, mustExist = FALSE)
            globals <- globals::cleanup(globals)
            where <- attr(globals, "where")
            keep <- !vapply(where, FUN = identical, envir, FUN.VALUE = NA)
            where <- where[keep]
            while (environmentName(envir) == "") {
              envir <- parent.env(envir)
            }
            keep <- !vapply(where, FUN = identical, envir, FUN.VALUE = NA)
            where <- where[keep]
            names <- lapply(where, FUN = environmentName)
            idxs <- grep("^imports:", names)
            for (idx in idxs) {
              name <- names(where)[idx]
              pkg <- sub("^imports:", "", names[idx])
              ns <- getNamespace(pkg)
              imports <- ns[[".__NAMESPACE__."]][["imports"]]
              if (length(imports) == 0) next
              froms <- names(imports)
              keep <- vapply(imports, FUN = is.element, name, FUN.VALUE = NA)
              from <- froms[keep]
              stopifnot(length(from) == 1L)
              names[idx] <- from
            }

            pkgs <- unlist(names)
            
            for (pkg in unique(pkgs)) {
              cat(sprintf("#' @importFrom %s %s\n", pkg, paste(names(pkgs)[pkgs == pkg], collapse = " ")))
            }
        }
  
        print_function(x, useSource = useSource, ...)
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



print_expression <- local({
    ## https://cran.r-project.org/web/packages/prettycode
    if (requireNamespace("prettycode", quietly = TRUE)) {
        print_expr <- prettycode:::print.function
    } else {
        print_expr <- base::print.function
    }
    
    function(x, ...) {
#        expr <- bquote(function() .(x))
#        fcn <- eval(expr)
#        body(fcn) <- x
#        fcn <- x
        environment(x) <- emptyenv()
        invisible(print_expr(x, useSource = FALSE))
     }
})


print.call <- print_expression

## Hmm... print() does not dispatch on `{`
`print.{` <- print_expression

## ... but this works
#print2 <- function(x, ...) UseMethod("print2")
#print2.call <- print_expression
#`print2.{` <- print_expression
