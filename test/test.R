library(spiker)

npoints <- 365 * 1

sig <- rep(1, npoints)



# for (i in 1:npoints) {
#   sig[i] <-  sin(2 * pi * i / 365) * cos(2 * pi * i / 365)
# }
sig[200:201] <- 1000


SpikeCenter(sig, 7, 0.1, 0.5, 10)
