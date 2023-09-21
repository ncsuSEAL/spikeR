#ifndef SPIKER_COMMON_H
#define SPIKER_COMMON_H


#include <Rcpp.h>
#include <Rinternals.h>
#include <cmath>

using namespace Rcpp;

double combined_stddev(NumericVector &x1, NumericVector &x2);


#endif
