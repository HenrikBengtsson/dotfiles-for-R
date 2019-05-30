try(local({
  email <- Sys.getenv("MY_CRAN_EMAIL", Sys.getenv("MY_EMAIL"))
  if (nzchar(email)) {
    with_nonstrict(foghorn::summary_cran_results(email))
    unloadNamespace("foghorn")
  }
}), silent = TRUE)

