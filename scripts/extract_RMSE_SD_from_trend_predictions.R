base_path <- "data/temp/"
file_paths <- list.files(base_path, pattern="MRP_1Br_testing")
library(lazyeval)
library(dplyr)

# Propogate the Month over Month values given a starting value
prop_MoM <- function (value, MoM_vals) 
{
  MoM_vals <- MoM_vals[-1]
  k <- length(MoM_vals)
  values <- c(value)
  if (k > 1) {
    for (i in 1:k ) {
      value <- MoM_vals[[i]]*value
      values <- c(values, value)
    }
  }
  return(values)
}

#z10035 <- filter(z10035, !is.na(MRP_1Br_trend))
#prop_MoM(z10035$MRP_1Br_trend[1], z10035$MRP_1Br_MoM)


RMSE <- function(actual, predicted, na.rm=TRUE){
  return(sqrt(mean(actual - predicted, na.rm=na.rm)^2))
}

extract_testing_trend_RMSE_SD_MRP_1Br <- function(file_paths){
  
  dat_lst <- list()
  # This function could be generalized by making 
  # a target argument to the function
  target <- "MRP_1Br_trend"
  
  for(training_end_file_path in file_paths){
    message(paste("Processing :", training_end_file_path))
    # Read and prepare data
    dat <- read.csv(paste0(base_path, training_end_file_path))
    dat$date <- as.Date(dat$date)
    dat$train_end_date <- as.Date(dat$train_end_date)
    # Get character form of date as list identifier
    train_end_date <- as.character(dat$train_end_date[1])
    
    # Acquire useful columns
    dat <- filter(dat, !is.na(MRP_1Br)) %>% 
      select(year, month, zipcode, date, train_end_date,
             MRP_1Br, MRP_1Br_trend, MRP_1Br_remainder, MRP_1Br_seasonal,
             MRP_1Br_MoM, MRP_1Br_raw_MoM,
             naive_preds, rf_preds, full_rf_preds)
    
    # Calculate trend from predictions
    trend_predictions <- dat %>% 
      filter(date >= train_end_date) %>% 
      group_by(zipcode) %>% 
      do({
        m <- filter(., !is.na(full_rf_preds)) %>% 
          select(date, train_end_date, zipcode, MRP_1Br, MRP_1Br_trend, full_rf_preds, rf_preds, naive_preds)
        try(
          m$rf_trend_preds <- prop_MoM(m$MRP_1Br_trend[1], m$rf_preds),
          silent=TRUE)
        try(
          m$full_rf_trend_preds <- prop_MoM(m$MRP_1Br_trend[1], m$full_rf_preds),
          silent=TRUE)
        try(
          m$naive_trend_preds <- prop_MoM(m$MRP_1Br_trend[1], m$naive_preds),
          silent=TRUE)
        m
      })
  
    trend_RMSE_SD <- trend_predictions %>%
      filter(date > train_end_date) %>% 
      mutate(days_in_future = date - train_end_date) %>% 
      group_by(date, days_in_future, zipcode) %>%
      summarise_(naive_trend_RMSE = interp(~ RMSE(target, naive_trend_preds), target=as.name(target)),
                 naive_trend_SD = interp(~ sd(naive_trend_preds, na.rm=TRUE)),
                 rf_trend_RMSE = interp(~ RMSE(target, rf_trend_preds), target=as.name(target)),
                 rf_trend_SD = interp(~ sd(rf_trend_preds, na.rm=TRUE)),
                 full_rf_trend_RMSE = interp(~ RMSE(target, full_rf_trend_preds), target=as.name(target)),
                 full_rf_trend_SD = interp(~ sd(full_rf_trend_preds, na.rm=TRUE)))
    
    dat_lst[[train_end_date]] <- trend_RMSE_SD

  }
  return(do.call(rbind.data.frame,dat_lst))
}


