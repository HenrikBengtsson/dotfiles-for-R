#' Configure option 'repos' for CRAN and Bioconductor
#'
#' The Bioconductor version is inferred from:
#'
#' 1. Environment variable `R_BIOC_VERSION`
#' 2. `utils::packageVersion("BiocVersion")`
#' 3. `BiocManager::version()`
#' 4. Mapping R version to manually curated version table
#'
#' Options that are set:
#' * `repos`
#'
#' Environment variables that are set:
#' * `R_BIOC_VERSION`
#'
#' @author Henrik Bengtsson
#' @imports utils BiocVersion BiocManager startup
if (!nzchar(Sys.getenv("R_CMD"))) {
  local({
    known_repos <- function() {
      p <- file.path(Sys.getenv("HOME"), ".R", "repositories")
      if (!file.exists(p)) p <- file.path(R.home("etc"), "repositories")
      ns <- getNamespace("tools")
      .read_repositories <- get(".read_repositories", envir = ns)
      ## NOTE: The following gives an error, if 'R_BIOC_VERSION' is not set
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
        if (utils::packageVersion("BiocManager") >= "1.30.5") {
          biocver <- as.character(BiocManager::version())
          unloadNamespace("BiocManager")
        } else {
          tryCatch({
            ## WARNING: The following call with query the Bioconductor
            ## web server (https://bioconductor.org/config.yaml) to infer
            ## the recommended Bioconductor version for this version of R
            ## NOTE: If it fails to connect, it will produce warnings
            ## saying so, but will not give an error
            biocver <- as.character(BiocManager:::.version_choose_best())
            unloadNamespace("BiocManager")
            ## Assert valid version, which is not the case if it failed
            ## to query the Bioconductor server. If not, undo.
            if (is.na(package_version(biocver, strict = FALSE))) biocver <- ""
          }, error = identity)
        }
        if (nzchar(biocver)) return(biocver)
      }, error = identity)
  
      # Ad hoc via the R version
      rver <- getRversion()
      biocver <- {
        if (rver >= "4.2.0") "3.15" else ## per 2021-10-27
        if (rver >= "4.1.1") "3.14" else ## per 2021-10-27
        if (rver >= "4.1.0") "3.13" else ## per 2020-10-28
        if (rver >= "4.0.3") "3.12" else ## per 2020-10-28
        if (rver >= "4.0.0") "3.11" else ## per 2019-10-30
        if (rver >= "3.6.1") "3.10" else ## per 2019-10-30
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
    } ## bioc_version()


    ## Query Bioconductor version in different ways
    v <- bioc_version()
    biocver <- package_version(v, strict = FALSE)
    if (is.na(biocver)) {
      stop(sprintf("Failed to infer Bioconductor version (from string %s). If set, make sure environment variable 'R_BIOC_VERSION' is set to valid version: %s", sQuote(v), Sys.getenv("R_BIOC_VERSION")))
    }
    Sys.setenv(R_BIOC_VERSION = v)
  
    repos <- c(
      getOption("repos"),
      known_repos(),
      "CRAN"       = "https://cloud.r-project.org",
      "CRANextra"  = if (.Platform$OS.type == "windows") {
                       "https://www.stats.ox.ac.uk/pub/RWin"
                     },
      "R-Forge"    = "http://R-Forge.R-project.org",
      "Omegahat"   = "http://www.omegahat.org/R",
      "rforge.net" = "https://www.rforge.net"
    )
  
    # Drop remaining '@...@' values
    repos <- grep("^@.*@$", repos, invert=TRUE, value=TRUE)
  
    # Drop miscellaneous 
    repos <- repos[!grepl("(CRANextra|Omegahat|R-Forge|rforge.net)", names(repos))]
  
    # Bioconductor tweaks
    if (!is.na(biocver)) {
      if (biocver >= "3.6") {
        repos <- repos[!grepl("BioCextra", names(repos))]
      }
      if (biocver >= "3.7") {
        repos["BioCworkflows"] <- gsub("bioc$", "workflows", repos[["BioCsoft"]])
      }
    }
  
    # Bring CRAN to the front
    idx <- match("CRAN", names(repos))
    if (!is.na(idx)) repos <- c(repos[idx], repos[-idx])
    
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
}

