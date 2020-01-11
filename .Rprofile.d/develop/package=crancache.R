## https://github.com/r-lib/crancache/issues/38
local({
  crancache_dir <- function() {
    ## Alt 1. Default R_LIBS_USER
    version <- c("%p", "%v")
    
    ## Alt 2. Customized R_LIBS_USER
    lib <- Sys.getenv("R_LIBS_USER")
    version <- c(basename(dirname(lib)), basename(lib))
    
    rappdirs::user_cache_dir("R-crancache", version = version, expand = TRUE)
  }			  
  Sys.setenv(CRANCACHE_DIR = crancache_dir())
})
