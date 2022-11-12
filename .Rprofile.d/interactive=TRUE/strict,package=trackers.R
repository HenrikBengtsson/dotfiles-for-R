invisible({
  library(trackers)
  addTaskCallback(tracker_envvars,   name = "Environment-variable tracker")
  addTaskCallback(tracker_files,     name = "Files tracker")
  addTaskCallback(tracker_globalenv, name = ".GlobalEnv tracker")
  addTaskCallback(tracker_options,   name = "Options tracker")
  tracker_locale(NULL) ## initiate locale tracker
  addTaskCallback(tracker_locale,    name = "Locale tracker")
  addTaskCallback(tracker_packages,  name = "Packages tracker")
  addTaskCallback(tracker_rng,       name = "RNG tracker")
  addTaskCallback(tracker_rplots,    name = "Rplots tracker")
  addTaskCallback(tracker_sink,      name = "Sink tracker")
})

trackers::trace_rng_on_load("on")
