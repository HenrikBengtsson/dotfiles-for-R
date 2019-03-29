options(prompt = "R on Wine> ")

local({
  repos <- getOption("repos")
  repos <- gsub("https:", "http:", repos, fixed=TRUE)
  options(repos = repos)
})
