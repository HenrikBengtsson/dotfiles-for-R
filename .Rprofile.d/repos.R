#' Configure option 'repos' for CRAN and Bioconductor
#'
#' Options that are set:
#' * `repos`
#'
#' Environment variables that are set:
#' * `R_BIOC_VERSION`
#'
#' @author Henrik Bengtsson
#' @imports utils BiocVersion BiocManager startup
local({
  known_repos <- function() {
    p <- file.path(Sys.getenv("HOME"), ".R", "repositories")
    if (!file.exists(p)) p <- file.path(R.home("etc"), "repositories")
    ns <- getNamespace("tools")
    .read_repositories <- get(".read_repositories", envir = ns)
    a <- .read_repositories(p)
    repos <- a$URL
    names(repos) <- rownames(a)
    repos
  }

  ## Bioconductor version
  bioc_version <- function() {
    biocver <- Sys.getenv("R_BIOC_VERSION")
    if (nzchar(biocver)) return(biocver)
    
    ## Via the BiocVersion package?
    tryCatch({
      biocver <- as.character(utils::packageVersion("BiocVersion")[, 1:2])
    }, error = identity)
    if (nzchar(biocver)) return(biocver)

    # Via the BiocManager package?
    ## WORKAROUND: BiocManager::version() can be very slow
    ## because it calls installed.packages().
    ## https://github.com/Bioconductor/BiocManager/pull/42
    tryCatch({
      biocver <- as.character(BiocManager:::.version_choose_best())
      unloadNamespace("BiocManager")
    }, error = identity)
    if (nzchar(biocver)) return(biocver)

    # Ad hoc via the R version
    rver <- getRversion()
    biocver <- {
      if (rver >= "3.6.0") "3.9" else
      if (rver >= "3.5.1") "3.8" else
      if (rver >= "3.5.0") "3.7" else
      if (rver >= "3.4.2") "3.6" else
      if (rver >= "3.4.0") "3.5" else
      if (rver >= "3.3.1") "3.4" else
      if (rver >= "3.3.0") "3.3" else
      if (rver >= "3.2.2") "3.2" else
      if (rver >= "3.2.0") "3.1" else
                           "3.0"
    }
  }

  Sys.setenv(R_BIOC_VERSION = bioc_version())
  biocver <- package_version(Sys.getenv("R_BIOC_VERSION"))

  repos <- c(
    CRAN = "https://cloud.r-project.org",
    CRANextra = if (.Platform$OS.type == "windows") {
      "https://www.stats.ox.ac.uk/pub/RWin"
    },
    "R-Forge" = "http://R-Forge.R-project.org",
    Omegahat = "http://www.omegahat.org/R",
    known_repos(),
    getOption("repos")
  )
  
  # Drop some
  repos <- repos[!grepl("(Omegahat|R-Forge|rforge.net)", names(repos))]

  # Drop R-Forge
  repos <- repos[!grepl("R-Forge", names(repos))]

  # Bioconductor tweaks
  if (biocver >= "3.6") {
    repos <- repos[!grepl("BioCextra", names(repos))]
  }
  if (biocver >= "3.7") {
    repos["BioCworkflows"] <- gsub("bioc$", "workflows", repos[["BioCsoft"]])
  }

  # Use HTTP when HTTPS is not supported
  if (getRversion() < "3.2.2" || startup::sysinfo()$wine) {
    repos <- gsub("https://", "http://", repos, fixed = TRUE)
  }

  # Keep only unique existing ones
  repos <- repos[!is.na(repos)]
  names <- names(repos)
  repos <- repos[!(nzchar(names) & duplicated(names))]

  options(repos = repos)
})
