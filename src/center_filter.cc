/**
 * Author(s):    Owen Smith, Jenna Abrahamson
 * Created:      04.23.2023
 * License:      MIT
 **/
#include "param.h"
#include "spiker.h"

/* What do we need?
   - Option to take a previous `spike` object and update for new data
 */

/*
  We have a spike_filter function which intially takes the parameters and the
  data.
  - spike_filter(signal, window, threshold, spikeAmp, timeframe)

*/

// [[Rcpp::export]]
IntegerVector C_spike_center(NumericVector &signal, List &parameter_list,
                             Nullable<IntegerVector> dates_idx = R_NilValue
            ) {
  // TODO: Reduce number of allocs happening. Should pass signal by ref and
  //       change to NA directly

  Parameters params(parameter_list);

  int window_floor = floor(params.window / 2);
  double center, pre_diff, post_diff;
  NumericVector pre, post;
  IntegerVector dates_idx_;

  // NOTE: Should move this logic into the R function
  if (dates_idx.isNull()) {
    dates_idx_ = seq_len(signal.size());
  } else {
    dates_idx_ = dates_idx;
  }

  dates_idx_ = dates_idx_[!is_na(signal)];
  signal = na_omit(signal);
  IntegerVector spikes(signal.size());

  if (signal.size() > params.window) {
    // Loop through windows
    for (int i = window_floor; i < (signal.size() - window_floor); ++i) {
      // Get observation of interest and window before/after
      center = signal[i];
      pre = signal[Range(i - window_floor, i - 1)];
      post = signal[Range(i + 1, i + window_floor)];

      // Get differences between median values before and after the
      // central observation
      pre_diff = center - median(pre);
      post_diff = median(post) - center;

      if (
          // If the differences before/after the central observation are
          // greater than the threshold deviations between the median
          // values pre- and post-observation of interest
          (fabs(pre_diff + post_diff) >=
           (params.threshold * combined_stddev(pre, post))) &&
          // And the range of dates is within the timeframe threshold
          ((dates_idx_[i + window_floor] - dates_idx_[i - window_floor]) <=
           params.timeframe)) {
        // If the difference before and after the central obs >= spike
        // amplitude
        if (((pre_diff <= -params.spike_amp) &&
             (post_diff >= params.spike_amp)) ||
            ((pre_diff >= params.spike_amp) &&
             (post_diff <= -params.spike_amp))) {

          spikes[i] = 1;
        }
      }
    }
  }

  return dates_idx_[spikes == 1];
}
