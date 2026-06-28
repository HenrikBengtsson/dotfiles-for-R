if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode") {
  if (requireNamespace("languageserver", quietly = TRUE)) {
    options(vsc.plot = FALSE) # Use httpgd instead if you have it
    # The extension usually injects the .vsc.attach() code here
  }
}
