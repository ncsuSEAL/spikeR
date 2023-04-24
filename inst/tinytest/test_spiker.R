library(spiker)

# Placeholder with simple test
expect_equal(1 + 1, 2)


test_center_simple <- function() {
    npoints <- 365 * 1
    sig <- rep(1, npoints)
    sig[200:201] <- 1000
    return(spikeCenter(sig, 7, 0.1, 0.5, 10))
}
expect_equal(test_center_simple(), c(200, 201))

test_center_seasonal <- function() {
    npoints <- 365 * 2
    sig <- rep(1, npoints)
    for (i in 1:npoints) {
      sig[i] <-  sin(2 * pi * i / 365) * cos(2 * pi * i / 365)
    }
    sig[400:401] <- 1
    sig[200:203] <- -10
    return(spikeCenter(sig, 7, 0.1, 0.2, 10))
}

expect_equal(test_center_seasonal(), c(400, 401))
