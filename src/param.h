#ifndef PARAM_H
#define PARAM_H

#include "common.h"
using namespace Rcpp;

// Object to store parameters
class CenterParameters {
public:
  int window;
  double threshold;
  double spike_amp;
  int timeframe;

  CenterParameters() {}

  CenterParameters(List params) :
    window{as<int>(params["window"])},
    threshold{as<double>(params["threshold"])},
    spike_amp{as<double>(params["spike_amp"])},
    timeframe{as<int>(params["timeframe"])} {}
};


class LaggingParameters {
public:
  int lag;                      // # of previous observations to use
  double threshold;             // z-score at which to signal a spike
  double influence;             // influence of new signals on mean and std

  LaggingParameters() {}

  LaggingParameters(List params) :
    lag{as<int>(params["lag"])},
    threshold{as<double>(params["threshold"])},
    influence{as<double>(params["influence"])}
    {}
};




#endif
