.verify_params <- function(window,
                           threshold,
                           spike_amp,
                           timeframe) {
  params <- list()

  params$window <- .mustBeInteger(
    x = window,
    minInt = 1L,
    "window"
  )

  params$threshold <- .mustBeNumeric(
    x = threshold,
    minNum = 0L,
    "threshold"
  )


  params$spike_amp <- .mustBeNumeric(
    x = spike_amp,
    minNum = 0L,
    "spike_amp"
  )

  params$timeframe <- .mustBeInteger(
    timeframe,
    minInt = 1L,
    "timeframe"
  )

  return(params)
}
