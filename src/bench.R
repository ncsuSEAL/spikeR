load("~/Data/test_d.Rdata")

ls()

dim(data_cube)

spike_amp <- 0.05
threshold <- 0.2
timeframe <- 200
window <- 7

spike_center <- function(signal, window = 7, threshold = 0.1, spike_amp = 0.2, timeframe = 100, dates = dates) {
  sig_df <- data.table::as.data.table(signal)
  pixel <- cbind(sig_df, "timestamp" = 1:length(dates))
  pixel <- na.omit(pixel)
  w_floor <- floor(window / 2)
  pixel$spike <- 0
  spike_dates <- c()
  if (nrow(pixel) > window) {
    # Loop through moving windows
    print(w_floor)
    for (i in (w_floor + 1):(nrow(pixel) - w_floor)) {
      # Determine observation of interest and window before/after
      center <- pixel[i, ] # Center observation of interest
      pre <- pixel[(i - w_floor):(i - 1), ] # Obs before date of interest
      post <- pixel[(i + 1):(i + w_floor), ] # Obs after date of interest

      # Calculate diffs between the median values before/after central obs
      pre_diff <- center$signal - median(pre$signal)
      post_diff <- median(post$signal) - center$signal
      # If differences before/after central obs > threshold deviations
      # between the median values pre- and post-obs of interest
      if ((abs(pre_diff + post_diff) >= (threshold * sd(c(
        pre$signal,
        post$signal
      ), na.rm = TRUE))) &
        # and the range of dates is within the timeframe threshold
        (max(post$timestamp) - min(pre$timestamp) <= timeframe)) {
        # If difference before AND after the central obs >= spike amplitude
        if (((pre_diff <= -spike_amp) & (post_diff >= spike_amp)) |
          ((pre_diff >= spike_amp) & (post_diff <= -spike_amp))) {
          # add this observation date to list of spike dates
          spike_dates <- c(spike_dates, pixel[i, timestamp])
        }
      }
    }
  }
  # If there's at least one spike date, add a "spike" column where 1 == spike
  if (length(spike_dates >= 1)) {
    pixel[timestamp %in% spike_dates, "spike"] <- 1 # spike found
  }
  # Return the input data with the added spike column, if any spikes detected
  screen <- pixel[which(spike == 1)]$timestamp
  return(screen)
}

screen_spikes <- function(signal_df, spikes) {
    for (row in 1:nrow(signal_df)) {
        tmp_ind <- c(spikes[[row]])
        tmp_ind <- unlist(tmp_ind)
        if(length(tmp_ind) == 0) {
          next
        } else {
          signal_df[row, tmp_ind] <- NA
        }
    }
    return(signal_df)
}



s_og <- spike_center(
    data_cube[10,,"ndvi"], window, threshold, spike_amp, timeframe, dates
)
s_og


band_spikes <- apply(data_cube[1:10, ,"ndvi"], 1, spiker::spike_center, window, threshold, spike_amp, timeframe)
band_spikes

band_spikes_og <- apply(data_cube[1:10, ,"vege"], 1, spike_center, window, threshold, spike_amp, timeframe, dates)

band_spikes_og

spikes <- c()

spikes <- c(spikes, band_spikes)
spikes
band_spikes

 data_cube[, , band_name] <- screen_spikes(data_cube[,,band_name],
          spikes = spikes)


spikes
d_filt <- screen_spikes(data_cube[1:10,,"ndvi"], spikes)
d_filt_og <- screen_spikes(data_cube[1:10,,"ndvi"], band_spikes_og)
data_cube[1,24,"ndvi"]
d_filt[1,27]

plot(dates, data_cube[1,,"ndvi"])
points(dates, d_filt[1,], col="red")
