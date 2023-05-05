#ifndef SPIKER_H
#define SPIKER_H

#include <Rcpp.h>
#include <Rinternals.h>

using namespace Rcpp;

double populationSD(NumericVector &x1, NumericVector&x2);


IntegerVector spikeCenter(
	NumericVector signal,
	int window,
	double threshold,
	double spikeAmp,
	int timeframe,
	Nullable<IntegerVector> dates_idx
);

IntegerVector spikeLag(
	NumericVector signal,
	int lag,
	double threshold,
	double influence,
	int timeframe
);

#endif