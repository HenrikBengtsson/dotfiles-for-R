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
  trackers::trace_rng_on_load("on")
}

