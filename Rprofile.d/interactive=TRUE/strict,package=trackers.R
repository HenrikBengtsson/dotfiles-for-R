if (interactive()) {
  trackers::track_envvars()
  trackers::track_files()
  trackers::track_globalenv()
  trackers::track_options()
  trackers::track_locale()
  trackers::track_packages()
  trackers::track_rng()
  trackers::track_rplots_files()
  trackers::track_sinks()
  trackers::track_connections()
  trackers::track_gc()
  trackers::track_time(threshold = 2.0)

  ## Never allow base::closeAllConnections() from taking place
  trackers::trace_closeAllConnections(action = "error")

  ## FIXME: The following results in loadNamespace("pkgload") giving an error
  ## /2023-03-09
#  trackers::trace_rng_on_load("on")
}
