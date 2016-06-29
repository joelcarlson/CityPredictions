# Now we have to deal with all of those CSV files we wrote....
library(lazyeval)
library(dplyr)

RMSE <- function(actual, predicted, na.rm=TRUE){
  return(sqrt(mean(actual - predicted, na.rm=na.rm)^2))
}
# Extract the difference between the target and
# naive_preds, full_rf_preds, and rf_preds for data after the 
# train end date
extract_testing_RMSE_SD <- function(target, file_paths){
  
  dat_lst <- list()
  
  for(training_end_file_path in file_paths){
    message(paste("Processing :", training_end_file_path))
    dat <- read.csv(paste0(base_path, training_end_file_path))
    dat$date <- as.Date(dat$date)
    dat$train_end_date <- as.Date(dat$train_end_date)
    # Get character form of date as list identifier
    train_end_date <- as.character(dat$train_end_date[1])
    
    dat_RMSE_SD <- dat %>%
      filter(date > train_end_date) %>% 
      mutate(days_in_future = date - train_end_date) %>% 
      group_by(date, days_in_future) %>%
      summarise_(naive_RMSE = interp(~ RMSE(target, naive_preds), target=as.name(target)),
                 naive_SD = interp(~ sd(naive_preds, na.rm=TRUE)),
                 rf_RMSE = interp(~ RMSE(target, rf_preds), target=as.name(target)),
                 rf_SD = interp(~ sd(rf_preds, na.rm=TRUE)),
                 full_rf_RMSE = interp(~ RMSE(target, full_rf_preds), target=as.name(target)),
                 full_rf_SD = interp(~ sd(full_rf_preds, na.rm=TRUE)))
    dat_lst[[train_end_date]] <- dat_RMSE_SD

  }
  return(do.call(rbind.data.frame,dat_lst))
}





  