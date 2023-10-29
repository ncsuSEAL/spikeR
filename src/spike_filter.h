#ifndef SPIKER_H
#define SPIKER_H

#include "common.h"
#include "utils.h"

IntegerVector
C_center_spike_filter(NumericVector signal, List &parameter_list,
                      Nullable<IntegerVector> dates_idx);

IntegerVector C_lagging_spike_filter(NumericVector signal,
                                     List &parameter_list);

#endif
