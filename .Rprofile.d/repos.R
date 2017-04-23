# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup a repositories
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
local({
  ## Update manually
  ## (should ideally be looked up dynamically, say,
  ##  once a week, and cached)
  if (getRversion() >= "3.4.0") {
    Sys.setenv(R_BIOC_VERSION="3.5")
  } else if (getRversion() >= "3.3.1") {
    Sys.setenv(R_BIOC_VERSION="3.4")
  } else if (getRversion() >= "3.3.0") {
    Sys.setenv(R_BIOC_VERSION="3.3")
  } else if (getRversion() >= "3.2.2") {
    Sys.setenv(R_BIOC_VERSION="3.2")
  } else if (getRversion() >= "3.2.0") {
    Sys.setenv(R_BIOC_VERSION="3.1")
  } else {
    Sys.setenv(R_BIOC_VERSION="3.0")
  }

  knownRepos <- function() {
    p <- file.path(Sys.getenv("HOME"), ".R", "repositories")
    if (!file.exists(p)) p <- file.path(R.home("etc"), "repositories")
    ns <- getNamespace("tools")
    .read_repositories <- get(".read_repositories", envir=ns)
    a <- .read_repositories(p)
    repos <- a$URL
    names(repos) <- rownames(a)
    repos
  } # knownRepos()

  repos <- c(
    CRAN="https://cloud.r-project.org",
    CRANextra = if (.Platform$OS.type == "windows") {
      "https://www.stats.ox.ac.uk/pub/RWin"
    },
    "R-Forge"="http://R-Forge.R-project.org",
    Omegahat="http://www.omegahat.org/R",
    knownRepos(),
#    AROMA="http://braju.com/R",
    getOption("repos")
  )
  # Drop some
  repos <- repos[!grepl("(Omegahat|R-Forge)", names(repos))]

  if (getRversion() < "3.2.2") {
    repos <- gsub("https://", "http://", repos, fixed=TRUE)
  }

  # Keep only unique existing ones
  repos <- repos[!is.na(repos)]
  names <- names(repos)
  repos <- repos[!(nzchar(names) & duplicated(names))]

  # Drop R-Forge
  repos <- repos[!grepl("R-Forge", names(repos))]
  
  options(repos=repos)
})
