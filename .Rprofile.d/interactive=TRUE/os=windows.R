## Make browseURL() on files works in more cases (also via Rscript)
options(browser=function(...) R.utils::shell.exec2(...))
