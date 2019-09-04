options(error = function() {
  ## Close any open 'stdout' sinks including
  ## any active capture.output()
  replicate(sink.number(), sink(NULL))
  if (interactive()) utils::recover()
})
