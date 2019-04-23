# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup a repositories
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
local({
  ## Bioconductor version
  ver <- Sys.getenv("R_BIOC_VERSION")
  if (!nzchar(ver)) {
    ## Via BiocVersion?
    tryCatch({
      ver <- as.character(utils::packageVersion("BiocVersion")[, 1:2])
      Sys.setenv(R_BIOC_VERSION = ver)
    }, error = identity)

    # Via BiocManager?
    if (!nzchar(ver)) {
      ## WORKAROUND: BiocManager::version() can be very slow
      ## because it calls installed.packages().
      ## https://github.com/Bioconductor/BiocManager/pull/42
      tryCatch({
        ver <- as.character(BiocManager:::.version_choose_best())
        Sys.setenv(R_BIOC_VERSION = ver)
        unloadNamespace("BiocManager")
      }, error = identity)
    }

    if (!nzchar(ver)) {
      rver <- getRversion()
      ver <- {
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
      Sys.setenv(R_BIOC_VERSION = ver)
    }
  }
  
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
  if (package_version(Sys.getenv("R_BIOC_VERSION")) >= "3.6") {
    repos <- repos[!grepl("BioCextra", names(repos))]
  }

  # Use HTTP when HTTPS is not supported
  if (getRversion() < "3.2.2" || startup::sysinfo()$wine) {
    repos <- gsub("https://", "http://", repos, fixed = TRUE)
  }

  # Keep only unique existing ones
  repos <- repos[!is.na(repos)]
  names <- names(repos)
  repos <- repos[!(nzchar(names) & duplicated(names))]

  # Drop R-Forge
  repos <- repos[!grepl("R-Forge", names(repos))]

  options(repos = repos)
})
