#' Finds Function Dependencies
#'
#' @param x A [base::function]
#'
#' @return A names list of imports.
#' The names corresponds to the packages being imported, and the
#' elements corresponds to objects being imported from each package.
#' If `x` does not have an environment, then NULL is returned.
#'
#' @details
#' This function requires the \pkg{globals} package.
#'
#' @examples
#' imports <- function_imports(purrr::map_df)
#' str(imports)
#' 
#' @importFrom globals globalsOf cleanup
function_imports <- function(x) {
  envir <- environment(x)
  if (is.null(envir)) return(NULL)
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
    keep <- vapply(imports, FUN = function(names) any(is.element(names, name)), FUN.VALUE = NA)
    from <- froms[keep]
    stopifnot(length(from) == 1L)
    names[idx] <- from
  }

  ## Group my packages
  names <- unlist(names, use.names = TRUE)
  pkgs <- unique(names)
  imports <- list()
  for (pkg in pkgs) {
    imports[[pkg]] <- names(names[names == pkg])
  }
  imports
}


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
#' @examples
#' print_function(purrr::map_df)
#' 
#' @imports prettycode
#' @importFrom utils getSrcFilename getSrcLocation
print_function_with_annotations <- local({
    ## https://cran.r-project.org/web/packages/prettycode
    if (requireNamespace("prettycode", quietly = TRUE)) {
        print_function <- prettycode:::print.function
    } else {
        print_function <- base::print.function
    }
    
    function(x, useSource = TRUE, ...) {
        envir <- environment(x)
        
        ## 1. Generate @importFrom comments, if possible
        if (!is.null(envir) && requireNamespace("globals", quietly = TRUE)) {
            imports <- function_imports(x)
            for (pkg in names(imports)) {
              cat(sprintf("#' @importFrom %s %s\n", pkg, paste(imports[[pkg]], collapse = " ")))
            }
        }

        ## 2. Print function
        print_function(x, useSource = useSource, ...)
        
        ## 3. Add source file information
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


## Override print() for 'function'
print.function <- print_function_with_annotations

## Override print() for 'S7_method' 
print.S7_method <- local({
  .fcn <- NULL
  
  function(...) {
    if (is.null(.fcn)) {
      fcn <- S7:::print.S7_method
      env <- new.env(parent = environment(fcn))
      env$print <- print_function_with_annotations
      environment(fcn) <- env
      .fcn <<- fcn
    }
    .fcn(...)
  }
})

print.call <- print_expression

## Hmm... print() does not dispatch on `{`
`print.{` <- print_expression

## ... but this works
#print2 <- function(x, ...) UseMethod("print2")
#print2.call <- print_expression
#`print2.{` <- print_expression
