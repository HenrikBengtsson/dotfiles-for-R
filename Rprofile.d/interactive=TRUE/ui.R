#' Smoother experience at the R command line
#'
#' Enables TAB completions, automatically set option `width` as the
#' terminal window is resized, and disable GUI dialogs as far as possible.
#'
#' Options that are set:
#' * `setWidthOnResize`
#' * `useFancyQuotes`
#'
#' @author Henrik Bengtsson
#'
#' @imports utils

## TAB completions
utils::rc.settings(ipck = TRUE)

## If set and TRUE, R run in a terminal using a recent readline library
## will set the width option when the terminal is resized.
options(setWidthOnResize = TRUE)

gui_dialogs("off")

# Use regular single quotes
options(useFancyQuotes = FALSE)
