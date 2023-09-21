#ifndef SPIKER_H
#define SPIKER_H

#include "common.h"
#include "utils.h"

IntegerVector C_spike_center(NumericVector &signal, List &parameter_list,
                             Nullable<IntegerVector> dates_idx);

IntegerVector spike_lag(NumericVector signal, int lag, double threshold,
                        double influence, int timeframe);

#endif
