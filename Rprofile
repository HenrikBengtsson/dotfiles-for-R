tryCatch(startup::startup(all = TRUE), error=function(ex) message(".Rprofile error: ", conditionMessage(ex)))
try(BioconductorX::use(unload = TRUE, timemachine = FALSE), silent = TRUE)
