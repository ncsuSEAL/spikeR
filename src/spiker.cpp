/**
 * Author(s):    Owen Smith, Jenna Abrahamson
 * Created:   	 04.23.2023
 * License:      MIT
 **/
#include "spiker.h"

double populationSD(NumericVector &x1, NumericVector &x2)
{
	int n1, n2;
    double x, q1, q2;

	n1 = x1.size();
	n2 = x2.size();

    // Sample variances
    q1 = (n1 - 1) * var(x1) + n1 * pow(mean(x1), 2);
    q2 = (n2 - 1) * var(x2) + n2 * pow(mean(x2), 2);

    // Combined mean
    x = (n1 * mean(x1) + n2 * mean(x2)) / (n1 + n2);

    return sqrt(((q1 + q2) - (n1 + n2)* pow(x, 2)) / (n1 + n2 - 1));

}

// [[Rcpp::export]]
IntegerVector spikeCenter(
	NumericVector signal,
	int window,
	double threshold,
	double spikeAmp,
	int timeframe,
	Nullable<IntegerVector> dates_idx = R_NilValue
) {

	int window_floor = floor(window / 2);
	double center, pre_diff, post_diff;
	NumericVector pre, post;
    IntegerVector dates_idx_;

    // NOTE: Should move this logic into the R function
    if (dates_idx.isNull())
    {
        dates_idx_ = seq_len(signal.size());
    } else {
        dates_idx_ = dates_idx;
    }

	dates_idx_ = dates_idx_[!is_na(signal)];
	signal = na_omit(signal);
	IntegerVector spikes(signal.size());


	if (signal.size() > window) {
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
			// greater than the threshold deviations between the median values 
			// pre- and post-observation of interest
				(
					fabs(pre_diff + post_diff) >= 
					(threshold * populationSD(pre, post))
				) && 
			// And the range of dates is within the timeframe threshold
				(
                    (dates_idx_[i + window_floor] - dates_idx_[i - window_floor]) <=
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

	return dates_idx_[spikes == 1];
}
