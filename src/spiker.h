#ifndef SPIKER_H
#define SPIKER_H

#include "common.h"
#include "utils.h"

IntegerVector spike_center(
	NumericVector signal,
	int window,
	double threshold,
	double spikeAmp,
	int timeframe,
	Nullable<IntegerVector> dates_idx
);

IntegerVector spike_lag(
	NumericVector signal,
	int lag,
	double threshold,
	double influence,
	int timeframe
);

#endif