library(spiker)

test_data <<- new.env()
# tinytest sets cwd to $PKG_SRC/tests
load("../data/test_data.Rdata", envir = test_data)

test_center_simple <- function() {
    sig <- test_data$simple_sig
    return(spikeCenter(sig, 5, 0.05, 0.05, 100))
}
expect_equal(test_center_simple(), c(200, 201))

test_center_seasonal <- function(dates_idx = NULL) {

    #` npoints <- 365 * 2
    #` sig <- rep(1, npoints)
    #` for (i in 1:npoints) {
    #`   sig[i] <-  sin(2 * pi * i / 365) * cos(2 * pi * i / 365)
    #` }
    #` sig[400:401] <- 1
    #` sig[200:203] <- -10
    #` sig[200:201] <- 1000

    sig <- test_data$harmonic_sig
    return(spikeCenter(sig, 5, 0.05, 0.05, 20, dates_idx))
}
expect_equal(test_center_seasonal(), c(200, 201, 202, 203, 400, 401))
expect_equal(test_center_seasonal(dates_idx = 1:(365 * 2)),
                                  c(200, 201, 202, 203, 400, 401))

test_real_data <- function() {
    signal_df <- test_data$signal_df
    return(spikeCenter(signal_df$y, 5, 0.2, 0.2, 365, signal_df$t))
}
expect_equal(test_real_data(), c(17544, 17849))
