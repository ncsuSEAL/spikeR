detach("package:spiker", unload=TRUE)
library(spiker)
library(tinytest)

test_data <<- new.env()
# tinytest sets cwd to $PKG_SRC/tests
load("../data/test_data.Rdata", envir = test_data)


test_center_simple <- function() {
    sig <- test_data$simple_sig
    return(spike_filter(
        sig,
        window = 5,
        threshold = 0.05,
        spike_amp = 0.05,
        timeframe = 100
    ))
}

expect_equal(test_center_simple()$outlier_idx, c(200, 201))

test_center_seasonal <- function(dates_idx = NULL) {
    # ` npoints <- 365 * 2
    # ` sig <- rep(1, npoints)
    # ` for (i in 1:npoints) {
    # `   sig[i] <-  sin(2 * pi * i / 365) * cos(2 * pi * i / 365)
    # ` }
    # ` sig[400:401] <- 1
    # ` sig[200:203] <- -10
    # ` sig[200:201] <- 1000

    sig <- test_data$harmonic_sig
    return(spike_filter(sig,
        window = 5,
        threshold = 0.05,
        spike_amp = 0.05,
        timeframe = 20,
        dates_idx = dates_idx
    ))
}
expect_equal(
    test_center_seasonal()$outlier_idx,
    c(200, 201, 202, 203, 400, 401)
)
expect_equal(
    test_center_seasonal(dates_idx = 1:(365 * 2))$outlier_idx,
    c(200, 201, 202, 203, 400, 401)
)

test_real_data <- function() {
    signal_df <- test_data$signal_df
    return(spike_filter(signal_df$y,
        window = 5,
        threshold = 0.2,
        spike_amp = 0.2,
        timeframe = 365,
        dates_idx = signal_df$t
    ))
}
expect_equal(test_real_data()$outlier_idx, c(17544, 17849))


test_iterative_update <- function() {
    sig <- test_data$simple_sig
    i <- min_pnts <- 20
    lower_bound <- 1
    previous <- NULL

    while (lower_bound < length(sig)) {
        sub_sig <- sig[lower_bound:i]
        sub_sig <- sub_sig[!is.na(sub_sig)]
        previous <- spike_filter(
            sub_sig,
            previous = previous,
            window = 5,
            threshold = 0.05,
            spike_amp = 0.05,
            timeframe = 100
        )


        i <- i + min_pnts
        lower_bound <- lower_bound + min_pnts

    }
    previous

    return(previous)
}
expect_equal(test_iterative_update()$outlier_idx, c(200, 201))


## test_iterative_update_real_data <- function() {
##     signal_df <- test_data$signal_df
##     sig <- signal_df$y
##     dates_idx <- signal_df$t
##     i <- min_pnts <- 20
##     lower_bound <- 1
##     previous <- NULL


##     while (lower_bound < length(sig)) {
##         sub_sig <- sig[lower_bound:i]
##         sub_sig <- sub_sig[!is.na(sub_sig)]
##         sub_dates_idx <- dates_idx[lower_bound:i]
##         sub_dates_idx <- sub_dates_idx[!is.na(sub_sig)]
##         previous <- spike_filter(
##             sub_sig,
##             window = 5,
##             threshold = 0.05,
##             spike_amp = 0.05,
##             timeframe = 100,
##             dates_idx = sub_dates_idx
##         )

##         i <- i + min_pnts
##         lower_bound <- lower_bound + min_pnts

##     }
##     previous
##     return(previous)
## }
## expect_equal(test_real_data()$outlier_idx, c(17544, 17849))
