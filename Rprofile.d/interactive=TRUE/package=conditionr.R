#' @importFrom startup on_session_enter
if (interactive() && (getRversion() >= "4.0.0") &&
    requireNamespace("conditionr", quietly = TRUE)) {
  startup::on_session_enter(quote({
    conditionr::conditionr_enable()
  }))
}

