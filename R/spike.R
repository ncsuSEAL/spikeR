#' Run online spike filter
#'
#' @description
#' `spike_filter()` runs an outlier filter on timeseries data and returns a
#' `Spike` object containing the indices of the outliers found in the original
#' data and all the information neccesary to run if more data becomes available.
#' It currently has two possible models. A moving window (center) and lagging
#' window (lag) model.
#'
#' @section Specifying model and parameters:
#'
#' Model parameters for `spike_filter()` must be specified explicitly.
#' E.g. if you wanted to use the lag model you could not do
#' `spike_filter(signal, NULL, "lag")`. Instead you would have to do
#' `spike_filter(signal, NULL, type = "lag")`. This is due to how the previous
#' model is passed into the function to allow for flexibility when calling it
#' iteratively. See the sections on each model type for more information.
#'
#' @section Center model:
#'
#' The center model is a moving window approach to outlier detection. It has the
#' following parameters:
#'
#' * `window` - the size of the moving window
#' * `threshold` - The number of stddev away from median to flag spike
#' * `spike_amp` - Spike amplitude (units of value being compared)
#' * `timeframe` - The timeframe which observations must fall within to be
#'  considered by the model
#' * `dates_idx` - Optional. A vector of dates corresponding to the time of each
#'  observation. Used by time frame
#'
#' @section Lag model:
#'
#' The lag model is a lagging or trailing window approach to outlier detection.
#' It has the following parameters:
#'
#' * `lag` - The lag of the moving window (# of obs to use)
#' * `threshold` - The z-score at which to signal a spike
#' * `influence` - The influence of new signals on mean and std
#'
#'
#' @examples
#' signal <- rep(1, 365)
#' sig_1 <- signal[1:100]
#' model <- spike_filter(sig_1, type = "lag", lag=7, influence = 1, threshold = 1)
#' sig_2 <- signal[100:365]
#' model_2 <- spike_filter(sig_2, model)
#'
#' model_2$oulier_idx
#' # [1] 30 201 202
#'
#'
#' @param signal Input time series. Either a numeric vector or something
#'  coercable into one
#' @param previous Optional. A previously run model containing neccesary
#'  information for the next iteration
#' @param ... Other options to intialize parameters for either the center or
#'  lagging model
#'
#' @returns An `Spike` model object
#'
#' @useDynLib spiker
#' @import Rcpp
#' @importFrom(stats,  "na.omit")
#' @include type_check.R init_params.R
#' @include RcppExports.R
#' @export
spike_filter <- function(signal,
                         previous = NULL,
                         ...,
                         type = "center",
                         window = 7,
                         threshold = 0.1,
                         spike_amp = 0.1,
                         timeframe = 10,
                         dates_idx = NULL,
                         lag = 3,
                         influence = 0.5) {
    ## NOTE/FIXME: not a fan of this style of interface, should change to
    ##             model specific interface.


    ## Get call
    matched_call <- match.call()
    ## Init results
    result <- list()

    if (is.null(previous)) {
        ## Either first time running or previous model not provided

        if (is.null(dates_idx)) { # initialize indicies for dates
            dates_idx <- seq_along(signal)
        }

        ## Run either moving window (center) filter or lagging window filter
        if (type == "center") {
            ## Set up parameters, and verify data types are correct
            params <- .verify_params_center(
                window = window,
                threshold = threshold,
                spike_amp = spike_amp,
                timeframe = timeframe
            )

            ## Run moving window and get the indicies indicated as
            ## outliers
            outlier_idx <- C_center_spike_filter(
                signal, params,
                dates_idx
            )
        } else if (type == "lag") {
            ## Set up parameters, and verify data types are correct
            params <- .verify_params_lag(
                lag = lag,
                threshold = threshold,
                influence = influence
            )

            ## Run moving window and get the indicies indicated as
            ## outliers
            outlier_idx <- C_lagging_spike_filter(signal, params)
        } else {
            ## if neither condition is true, logic isn't working as expected.
            stop("unexpected filter type; use either 'center' or 'lag'.")
        }
    } else if (methods::is(object = previous, class2 = "Spike")) {
        ## Model has been included run next iteration
        params <- previous$params

        ## It is assumed that the next iteration will be a continuation
        ## of the initial data stream, therefore the next iterations
        ## outlier indicies will be greater than the outlier indicies
        ## of the previous.
        if (!is.null(dates_idx)) {
            dates_idx <- c(previous$prev_dates, dates_idx)
        } else {
            dates_idx <- c(
                previous$prev_dates,
                max(previous$prev_dates) + seq_along(signal)
            )
        }

        ## Prepend the stored data points of the previous model to the
        ## current iterations data
        signal <- c(previous$prev_pnts, signal) # Add previous windowed pnts
        previous_idx_pnts <- previous$outlier_idx

        ## Don't need to verify params as we are pulling from previous
        ## model
        if (params$type == "center") {
            outlier_idx <- C_center_spike_filter(
                signal, params,
                dates_idx
            )
        } else if (params$type == "lag") {
            outlier_idx <- C_lagging_spike_filter(signal, params)
        }

        ## Update the models outlier index
        outlier_idx <- unique(
            c(previous_idx_pnts, dates_idx[outlier_idx])
        )
    } else {
        ## if neither condition is true, logic isn't working as
        ## expected.
        stop("unexpected Spike object; contact developer")
    }

    ## We want to perserve only the non NA values
    signal_na <- na.omit(signal)
    if (params$type == "center") {
        ## Center only keep window % 2 points
        ts_tail <- (length(signal_na) -
            (params$window %/% 2) + 1):length(signal_na)
    } else {
        ts_tail <- (length(signal_na) -
            params$lag + 1):length(signal_na)
    }
    ## Data streams with less points than window % 2 or the lag
    ## results in negative indices, remove those
    ts_tail <- ts_tail[which(ts_tail > 0)]

    ## Populate model object
    result$prev_pnts <- signal_na[ts_tail]
    result$prev_dates <- dates_idx[ts_tail]
    result$params <- params
    result$matched_call <- matched_call
    result$outlier_idx <- outlier_idx

    class(x = result) <- c("Spike", class(x = result))

    return(result)
}
