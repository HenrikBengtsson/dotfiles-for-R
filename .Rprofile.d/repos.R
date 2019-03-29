# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup a repositories
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
local({
  ## Update automatically or manually?
  if (suppressMessages(requireNamespace("BiocManager", quietly = TRUE))) {
    ## WORKAROUND: BiocManager::version() can be very slow
    ## because it calls installed.packages().
    ## https://github.com/Bioconductor/BiocManager/pull/42
    BiocManager_version <- function() {
      tryCatch({
        packageVersion("BiocVersion")[, 1:2]
      }, error = function(ex) BiocManager:::.version_choose_best())
    }
    Sys.setenv(R_BIOC_VERSION = as.character(BiocManager_version()))
    unloadNamespace("BiocManager")
  } else {
    if (getRversion() >= "3.6.0") {
      Sys.setenv(R_BIOC_VERSION = "3.9")
    } else if (getRversion() >= "3.5.1") {
      Sys.setenv(R_BIOC_VERSION = "3.8")
    } else if (getRversion() >= "3.5.0") {
      Sys.setenv(R_BIOC_VERSION = "3.7")
    } else if (getRversion() >= "3.4.2") {
      Sys.setenv(R_BIOC_VERSION = "3.6")
    } else if (getRversion() >= "3.4.0") {
      Sys.setenv(R_BIOC_VERSION = "3.5")
    } else if (getRversion() >= "3.3.1") {
      Sys.setenv(R_BIOC_VERSION = "3.4")
    } else if (getRversion() >= "3.3.0") {
      Sys.setenv(R_BIOC_VERSION = "3.3")
    } else if (getRversion() >= "3.2.2") {
      Sys.setenv(R_BIOC_VERSION = "3.2")
    } else if (getRversion() >= "3.2.0") {
      Sys.setenv(R_BIOC_VERSION = "3.1")
    } else {
      Sys.setenv(R_BIOC_VERSION = "3.0")
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
