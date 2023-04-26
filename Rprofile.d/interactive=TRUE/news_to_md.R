#' @importFrom utils file_test
#' @importFrom tools toTitleCase
news_to_md <- function(pkg = ".", input = "NEWS", output = "NEWS.md", overwrite = FALSE, package = NULL, style = c("tidyverse", "NEWS"), header_case = c("TitleCase", "as-is"), escape = FALSE, collapse = "\n") {
  toTitleCase <- tools::toTitleCase
  
  style <- match.arg(style)
  header_case <- match.arg(header_case)
  
  stopifnot(file_test("-d", pkg))

  pathname <- file.path(pkg, input)
  stopifnot(file_test("-f", pathname))

  if (is.null(package)) {
    desc <- file.path(pkg, "DESCRIPTION")
    stopifnot(file_test("-f", desc))
    desc <- read.dcf(file = desc)
    package <- desc[, "Package"]
  }

  news <- tools:::.news_reader_default(pathname)

  if (is.character(output)) {
    stopifnot(overwrite || !file_test("-f", output))
  } else {
    stopifnot(inherits(output, "connection"))
  }

  ## Sanity check
  bad <- which(attr(news, "bad"))
  if (length(bad) > 0) {
    news_bad <- news[bad, ]
    msg <- sprintf("Detected %d malformed entries in %s: %s",
                   nrow(news_bad), sQuote(pathname),
                   paste(news_bad$Version, collapse = ", "))
    stop(msg)
  }

  ## Split up in releases
  releases <- split(news, news$Version)

  ## Preserve order according to NEWS
  if (length(releases) > 1) {
    releases <- releases[unique(news$Version)]
  }

  mds <- lapply(releases, FUN = function(release) {
    version <- unique(release$Version)
    stopifnot(length(version) == 1L)
    
    date <- unique(release$Date)
    stopifnot(length(date) == 1L)

    if (style == "NEWS") {
      header <- sprintf("## Version %s", version)
    } else if (style == "tidyverse") {
      header <- sprintf("# %s %s", package, version)
    }
    
    if (nzchar(date)) {
      header <- sprintf("%s [%s]", header, date)
    }

    ## Split up in categories
    categories <- split(release, release$Category)
    
    ## Preserve order according to NEWS
    if (length(categories) > 1) {
      categories <- categories[unique(release$Category)]
    }

    mds <- lapply(categories, FUN = function(category) {
      title <- unique(category$Category)
      stopifnot(length(title) == 1L)

      if (header_case == "TitleCase") {
        title <- tolower(title)
        title <- toTitleCase(title)
      }
      
      header <- sprintf("### %s", title)
      texts <- category$Text

      ## Drop newlines?
      if (FALSE) {
        texts <- lapply(texts, FUN = function(text) {
          text <- strsplit(text, split = "[\n\r]", fixed = FALSE)
          text <- unlist(text, use.names = FALSE)
          text <- paste(text, collapse = " ")
          text
        })
        texts <- unlist(texts, use.names = FALSE)
      }

      ## Escape Markdown?
      if (escape) {
        texts <- gsub("_", "\\_", texts, fixed = TRUE)
        texts <- gsub("*", "\\*", texts, fixed = TRUE)
        texts <- gsub("`", "\\`", texts, fixed = TRUE)
      }

      ## Inline simple commands
      texts <- gsub("([[:space:]/]*)([[:alnum:]_.]+[(][^)]*[)])([[:space:]/.,])", "\\1`\\2`\\3", texts, perl = TRUE)

      ## Inline simple commands of second degree
      texts <- gsub("([[:space:]/]*)([[:alnum:]_.]+[(][^)]*[(][^)]*[)][)])([[:space:]/.,])", "\\1`\\2`\\3", texts, perl = TRUE)

      ## Inline simple arguments
      texts <- gsub("([[:space:]]*)([[:alnum:]_.]+[[:space:]]*=[[:space:]]*[\"']*[[:alnum:]_.]*[\"']*)([[:space:].,])", "\\1`\\2`\\3", texts, perl = TRUE)

      ## Turn quoted command strings into inline commands
      texts <- gsub("([[:space:]])'([[:alnum:]:-]+)'([[:space:].,])", "\\1`\\2`\\3", texts, perl = TRUE)

      ## Drop newlines
      texts <- gsub("\n", " ", texts)
      
      items <- sprintf(" * %s", texts)
      mds <- c(header, items)
      mds <- unlist(rbind(mds, ""), use.names = FALSE)
      mds
    })

    mds <- c(header, mds)
    mds <- unlist(rbind(mds, ""), use.names = FALSE)
  })

  if (style == "NEWS") {
    header <- sprintf("# Package %s", sQuote(package))
  } else if (style == "tidyverse") {
    header <- NULL
  }

  mds <- c(header, mds)
  
  mds <- unlist(mds, use.names = FALSE)
  writeLines(mds, con = output)
  
  if (!is.null(collapse)) mds <- paste(mds, collapse = collapse)
  invisible(mds)
}
