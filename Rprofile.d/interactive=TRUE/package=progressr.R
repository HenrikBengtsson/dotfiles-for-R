#' @importFrom startup on_session_enter
if (interactive() && requireNamespace("progressr", quietly = TRUE)) {
  ## Enable global progression updates
  if (getRversion() >= "4.0.0") {
    startup::on_session_enter(quote({
      progressr::handlers(global = TRUE)
    }))
  }

  ## In RStudio Console?
  if (Sys.getenv("RSTUDIO") == "1" && !nzchar(Sys.getenv("RSTUDIO_TERM"))) {
    options(progressr.handlers = progressr::handler_rstudio)
  } else {
#    options(progressr.handlers = progressr::handler_progress(format = ":spin :current/:total (:message) [:bar] :percent in :elapsed ETA: :eta"))
    options(progressr.handlers = progressr::handler_cli)
  }
}

