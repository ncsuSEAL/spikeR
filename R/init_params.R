.verify_params_center <- function(
  window,
  threshold,
  spike_amp,
  timeframe
) {
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

  params$type <- "center"

  return(params)
}

.verify_params_lag <- function(
  lag,
  threshold,
  influence
) {
  params <- list()

  params$lag <- .mustBeInteger(
    x = lag,
    minInt = 1L,
    "lag"
  )

  params$threshold <- .mustBeNumeric(
    x = threshold,
    minNum = 0L,
    "threshold"
  )


  params$influence <- .mustBeNumeric(
    x = influence,
    minNum = 0L,
    "influence"
  )

  params$type <- "lag"


  return(params)
}
