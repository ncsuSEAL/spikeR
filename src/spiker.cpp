/**
 * Author(s):    Owen Smith, Jenna Abrahamson
 * Created:   	 04.23.2023
 * License:      MIT
 **/
#include "spiker.h"

double populationSD(NumericVector &x1, NumericVector&x2)
{
	int n1, n2;

	n1 = x1.size();
	n2 = x2.size();
	return (n1 * mean(x1) + n2 * mean(x2)) / (n1 + n2);
}

// [[Rcpp::export]]
IntegerVector SpikeCenter(
	NumericVector signal,
	int window,
	double threshold,
	double spikeAmp,
	int timeframe
) {


	int window_floor = floor(window / 2);
	double center, pre_diff, post_diff;
	NumericVector pre, post;

	// Create date index from 1:n and remove all NA's in signal
	IntegerVector dates_idx = seq_len(signal.size());
	dates_idx = dates_idx[!is_na(signal)];

	signal = na_omit(signal);

	IntegerVector spikes(signal.size());


	if (signal.size() > window) {
		// Loop through windows
		for (int i = window; i < (signal.size() - window_floor); ++i) {
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
			// greater than the threshold deviations between the median values 
			// pre- and post-observation of interest
				(
					abs(pre_diff) + abs(post_diff) >= 
					(threshold * populationSD(pre, post))
				) && 
			// And the range of dates is within the timeframe threshold
				(
					max(dates_idx[Range(i + 1, i + window_floor)]) -
					min(dates_idx[Range(i + 1, i + window_floor)]) <= 
					timeframe 
				)
				) {
				// If the difference before and after the central obs >= spike
				// amplitude
				if (
					((pre_diff <= -spikeAmp) && (post_diff >= spikeAmp)) ||
					((pre_diff >= spikeAmp) && (post_diff <= -spikeAmp))
				) {

					spikes[i] = 1;
				}

			}

		}

	}

	return dates_idx[spikes == 1];
}
