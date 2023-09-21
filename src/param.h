#ifndef PARAM_H
#define PARAM_H

#include "common.h"
using namespace Rcpp;

// Object to store parameters
class Parameters {
public:
  int window;
  double threshold;
  double spike_amp;
  int timeframe;

  Parameters() {}

  Parameters(List params)
      : window{as<int>(params["window"])}, threshold{as<double>(
                                               params["threshold"])},
        spike_amp{as<double>(params["spike_amp"])}, timeframe{as<int>(
                                                      params["timeframe"])} {}
};

#endif
