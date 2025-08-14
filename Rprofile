tryCatch(startup::startup(all = TRUE), error=function(ex) message(".Rprofile error: ", conditionMessage(ex)))
try(BioconductorX::use(unload = TRUE, timemachine = FALSE), silent = TRUE)

## Register global calling handler for 'progressr' here. We need to
## do it here, because startup::startup() runs within tryCatch()
progressr::handlers(global = TRUE)
