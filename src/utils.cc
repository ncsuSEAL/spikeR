#include "common.h"

// TODO: Exapand to accept K number groups
double combined_stddev(NumericVector &x1, NumericVector &x2)
{
    int n;
    double x, q1, q2;

    n = x1.size();
    if (n != x2.size()) {
        throw std::invalid_argument("Vectors should be same length");
    }

    // Sample variances
    q1 = (n - 1) * var(x1) + n * pow(mean(x1), 2);
    q2 = (n - 1) * var(x2) + n * pow(mean(x2), 2);

    // Combined mean
    x = (n * mean(x1) + n * mean(x2)) / (n + n);

    // TODO: change n * 2 -> n * k
    return sqrt(((q1 + q2) - (n * 2) * pow(x, 2)) / (n * 2 - 1));

}


