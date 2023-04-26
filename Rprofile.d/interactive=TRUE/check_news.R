#' @importFrom utils file_test
check_news <- function(pathname = c("NEWS", "NEWS.md")) {
  keep <- utils::file_test("-f", pathname)
  if (!any(keep)) {
    stop("No such file: ", paste(sQuote(pathname), collapse = ", "))
  }
  pathname <- pathname[keep]
  pathname <- pathname[1]

  if (basename(pathname) == "NEWS") {
    news <- tools:::.news_reader_default(pathname)
    bad <- which(attr(news, "bad"))
    if (length(bad) > 0) {
      news_bad <- news[bad, ]
      msg <- sprintf("Detected %d malformed entries in %s: %s",
                     nrow(news_bad), sQuote(pathname),
                     paste(news_bad$Version, collapse = ", "))
      stop(msg, call. = FALSE)
    }
  } else if (basename(pathname) == "NEWS.md") {
    news <- tools:::.build_news_db_from_package_NEWS_md(pathname)
    if (is.null(news)) {
      stop("Failed to parse news entries: ", sQuote(pathname))
    }
  }
  
  news
}
