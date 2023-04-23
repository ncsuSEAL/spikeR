#ifndef SPIKER_H
#define SPIKER_H


#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

double populationSD(NumericVector &x1, NumericVector&x2);


IntegerVector SpikeCenter(
	NumericVector signal,
	int window,
	double threshold,
	double spikeAmp,
	int timeframe
);


#endif