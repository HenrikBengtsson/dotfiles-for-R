install-startup:
	## CRAN
	Rscript -e 'install.packages("startup")'

install-cran:
	## CRAN
	Rscript -e 'install.packages(c("tuneR", "progressr", "foghorn", "R.utils", "prompt", "fortunes", "ps", "crayon", "profmem", "prettycode"))'

install-bioc:
	## Bioconductor
	Rscript -e 'install.packages(c("BiocVersion", "BiocManager"))'

install-github:
	## GitHub
	Rscript -e 'remotes::install_github(paste("r-lib", c("crancache"), sep = "/"))'

install-hb-private:
	## Henrik Bengtsson's private packages
	Rscript -e 'remotes::install_github(paste("HenrikBengtsson", c("tabby", "history", "fzf", "trackers"), sep = "/"))'
