#' Settings for CRAN, Bioconductor, and Posit Package Manager
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
#' * `HTTPUserAgent` (if Posit Package Manager is used)
#'
#' Environment variables that are set:
#' * `R_BIOC_VERSION`
#'
#' @author Henrik Bengtsson
#' @imports utils BiocVersion BiocManager startup
if (!nzchar(Sys.getenv("R_CMD"))) {
  local({
    ## -----------------------------------------------------------------
    ## CRAN repository
    ## -----------------------------------------------------------------
    known_repos <- function() {
      p <- file.path(Sys.getenv("HOME"), ".R", "repositories")
      if (!file.exists(p)) p <- file.path(R.home("etc"), "repositories")
      ## Find .read_repositories() - moved to 'utils' in R (>= 4.3.0)
      .read_repositories <- NULL
      for (pkg in c("tools", "utils")) {
        ns <- getNamespace(pkg)
        if (exists(".read_repositories", envir = ns, inherits = FALSE)) {
          .read_repositories <- get(".read_repositories", envir = ns, inherits = FALSE)
          break
        }
      }
      ## NOTE: The following gives an error, if 'R_BIOC_VERSION' is not set
      a <- .read_repositories(p)
      repos <- a[["URL"]]
      names(repos) <- rownames(a)
      repos
    }


    ## -----------------------------------------------------------------
    ## Bioconductor repository
    ## -----------------------------------------------------------------
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
        if (rver >= "4.5.0") "3.21" else ## per 2024-10-30
        if (rver >= "4.4.2") "3.20" else ## per 2024-10-30
        if (rver >= "4.4.0") "3.19" else ## per 2024-05-01
        if (rver >= "4.3.1") "3.18" else ## per 2023-10-25
        if (rver >= "4.3.0") "3.17" else ## per 2023-04-26
        if (rver >= "4.2.2") "3.16" else ## per 2022-11-02
        if (rver >= "4.2.0") "3.15" else ## per 2022-04-27
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
      "CRANextra"  = if (.Platform[["OS.type"]] == "windows") {
                       "https://www.stats.ox.ac.uk/pub/RWin"
                     },
      "R-Forge"    = "http://R-Forge.R-project.org",
      "rforge.net" = "https://www.rforge.net"
    )
  
    # Drop remaining '@...@' values
    repos <- grep("^@.*@$", repos, invert=TRUE, value=TRUE)
  
    # Drop miscellaneous 
    repos <- repos[!grepl("(CRANextra|R-Forge|rforge.net)", names(repos))]
  
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
    if (getRversion() < "3.2.2" || startup::sysinfo()[["wine"]]) {
      repos <- gsub("https://", "http://", repos, fixed = TRUE)
    }
  
    # Keep only unique existing ones
    repos <- repos[!is.na(repos)]
    names <- names(repos)
    repos <- repos[!(nzchar(names) & duplicated(names))]
  
    options(repos = repos)
  })


  ## -------------------------------------------------------------------
  ## Posit Package Manager (PPM)
  ## -------------------------------------------------------------------
  ## Use Posit Package Manager to install prebuild packages for Linux?
  if (.Platform[["OS.type"]] == "unix") {
    distro <- NA_character_

    ## Infer Linux distro from Sys.info()?
    ver <- Sys.info()[["version"]]
    if (grepl("Ubuntu", ver)) {
      if (grepl("22[.]04.*Ubuntu", ver)) {
         distro <- "jammy" ## Ubuntu 22.04
      } else if (grepl("20[.]04.*Ubuntu", ver)) {
         distro <- "focal" ## Ubuntu 20.04
      }
    }

    ## Infer Linux distro from /etc/os-release?
    if (is.na(distro) && file.exists("/etc/os-release")) {
       get_field <- function(name, bfr) {
         pattern <- sprintf("^%s=", name)
         value <- grep(pattern, bfr, value = TRUE)
         gsub('(^[^=]+=["]?|["]?$)', "", value)
       }
       bfr <- readLines("/etc/os-release")

       ## Condition on Linux distribution
       name <- get_field("NAME", bfr)
       if (name == "Ubuntu") {
         codename <- get_field("VERSION_CODENAME", bfr)
         if (nzchar(codename)) {
           distro <- codename
         }
       } else if (name == "Rocky Linux") {
         platform_id <- get_field("PLATFORM_ID", bfr)
         if (nzchar(platform_id)) {
           pattern <- "^platform:(el[[:digit:]]+)$"
           if (grep(pattern, platform_id)) {
             rhel_id <- gsub(pattern, "\\1", platform_id)
             rhel_id <- sprintf("rh%s", rhel_id)
             if (rhel_id %in% c("rhel9")) {
               distro <- rhel_id
             }
           }
         }
       }
    }

    if (!is.na(distro)) {
      options(repos = c(
        PPM = sprintf("https://packagemanager.posit.co/cran/__linux__/%s/latest", distro),
        getOption("repos")
      ))

      options(
        HTTPUserAgent = sprintf("R/%s R (%s)",
          getRversion(),
          paste(
            getRversion(),
            R.version[["platform"]],
            R.version[["arch"]],
            R.version[["os"]]
          )
        )
      )
    }
  }
}
