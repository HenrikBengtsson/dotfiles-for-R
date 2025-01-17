#' Get the Dependency Graph of Currently Loaded Namespaces
#'
#' @return A logical square matrix representing the dependency graph.
#'
#' @seealso
#' [base::loadedNamespaces]
#'
#' @export
namespace_graph <- function() {
  namespaces <- loadedNamespaces()
  graph <- matrix(FALSE,
    nrow = length(namespaces), ncol = length(namespaces),
    dimnames = rep(list(namespaces), times = 2L)
  )
                  
  ## Get all namespaces
  nss <- lapply(namespaces, FUN = getNamespace)
  names(nss) <- namespaces

  ## Identify all namespaces that imports the namespace of interest
  imports <- lapply(nss, FUN = function(ns) {
    meta <- ns[[".__NAMESPACE__."]]
    unique(names(meta[["imports"]]))
  })
  names(imports) <- namespaces

  for (name in namespaces) {
    graph[name, imports[[name]]] <- TRUE
  }

  ## A namespace should never import itself
  stopifnot(!any(diag(graph)))

  ## Reorder
  o <- order(colSums(graph), decreasing = TRUE)
  graph <- graph[, o, drop=FALSE]
  
  graph
}


#' Identify Why a Certain Namespace is Loaded
#'
#' @param name ([base::character] or [base::namespace])
#' Name of the namespace to be investigated.
#'
#' @return A character vector of namespaces that depend on the
#' namespace of interest.
#'
#' @export
why_namespace <- function(name, depth = 0, drop = TRUE) {
  if (isNamespace(name)) {
    ns <- name
    name <- ns[[".packageName"]]
  }
  stopifnot(is.character(name))
  if (!isNamespaceLoaded(name)) {
    stop("Namespace is not loaded: ", sQuote(name))
  }

  ## Get the namespace dependency graph
  deps <- namespace_graph()

  parent_namespaces <- function(name, depth = Inf) {
    ## Identify which package imports our namespace
    pkg_names <- deps[, name, drop = TRUE]
    imported_by <- names(pkg_names)[pkg_names]

    ## A namespace should never import itself
    stopifnot(!name %in% imported_by)
    
    parents <- rep(list(name), times = length(imported_by))
    names(parents) <- imported_by
    is_attached <- sprintf("^package:%s$", imported_by)

    if (depth > 0) {
      grandparents <- list()
      for (kk in seq_along(parents)) {
        parent <- parents[kk]
        grandparents0 <- parent_namespaces(names(parent), depth = depth - 1)
        if (length(grandparents0) == 0) {
          grandparents <- c(grandparents, parent)
        } else {
          for (jj in seq_along(grandparents0)) {
            grandparents0[[jj]] <- c(grandparents0[[jj]], parent)
          }
          utils::str(list(parents = parents, parent = parent, grandparents0 = grandparents0, grandparents = grandparents))
          grandparents <- c(grandparents, grandparents0)
        }
      }
      parents <- grandparents
    }

    is_attached <- sprintf("package:%s", names(parents)) %in% search()
    names(parents)[is_attached] <- sprintf("%s*", names(parents)[is_attached])

    parents
  }
  
  parents <- parent_namespaces(name, depth = depth)

#  parents <- lapply(parents, FUN = unlist, use.names = FALSE)

  if (drop && depth == 0) parents <- unlist(parents)
  parents
}


