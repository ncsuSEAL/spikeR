#' @useDynLib spiker
#' @import Rcpp
#' @include type_check.R init_params.R
#' @include RcppExports.R
#' @export
spike_filter <- function(
    signal, previous = NULL, ...,
    window = 7,
    threshold = 0.1,
    spike_amp = 0.1,
    timeframe = 10,
    dates_idx = NULL) {

  matched_call <- match.call()

  result <- list()



  if (is.null(previous)) {

    # initialize dates_idx
    if (is.null(dates_idx)) {
        dates_idx <- seq_along(signal)
    }
    # Either first time running or previous model not provided

    # Set up parameters and type check their contents
    params <- .verify_params(
      window = window,
      threshold = threshold,
      spike_amp = spike_amp,
      timeframe = timeframe
    )

    # Run and get outlier idx's
    outlier_idx <- C_spike_center(signal, params, dates_idx)

  } else if (methods::is(object = previous, class2 = "Spike")) {
    params <- previous$params


    # Keep track of dates idx's
    if (!is.null(dates_idx)) {
        dates_idx <- c(previous$prev_dates, dates_idx)
    } else {
        dates_idx <- c(previous$prev_dates,
                       max(previous$prev_dates) + seq_along(signal))
    }

    signal <- c(previous$prev_pnts, signal) # Add previous windowed pnts
    previous_idx_pnts <- previous$outlier_idx


    outlier_idx <- C_spike_center(signal, params, dates_idx)
    outlier_idx <- c(previous_idx_pnts, outlier_idx) # Update outlier idx
  } else {
    # if neither condition is true, logic isn't working as expected.
    stop("unexpected Spike object; contact developer")
  }

  result$prev_pnts <- signal[(length(signal) - (window %/% 2)):length(signal)]
  result$prev_dates <- dates_idx[(length(signal) - (window %/% 2)):length(signal)]
  result$params <- params
  result$matched_call <- matched_call
  result$outlier_idx <- outlier_idx

  class(x = result) <- c("Spike", class(x = result))

  return(result)
}
