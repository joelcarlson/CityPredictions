library(forecast); library(dplyr)

# Functions to Extract the trend, seasonal fluctuation, and remainder 
# from each variable for each zipcode

create_time_series_by_variable <- function(zip_dat, variable, end_date=c(2014,6)){
  dat_subset <- zip_dat[!is.na(zip_dat[[variable]]), c("year", "month", variable)]
  if(nrow(dat_subset) < 12){
    return(NULL)
  }
  dat_ts <- ts(dat_subset, deltat=1/12, start=c(dat_subset$year[1], dat_subset$month[1]), end=end_date)
  return(dat_ts)
}


get_STL_df_by_variable <- function(time_series, variable, zip){
  # Decompose the time series 
  ts_stl <- tryCatch({
    stl(time_series[,variable], s.window=12, robust=TRUE)
  }, error = function(e) {
    return(NULL)
  })
  if(is.null(ts_stl)) return(NULL)
  
  stl_df <- as.data.frame(ts_stl$time.series)
  
  # Rename the columns
  colnames(stl_df) <- paste0(variable, "_", colnames(stl_df) )
  stl_df$year <- as.numeric(time_series[,'year'])
  stl_df$month <- as.numeric(time_series[,'month'])
  stl_df$date <- as.Date(paste0(stl_df$year, '-', stl_df$month, '-15'))
  
  # Add a zipcode column to uniquely identify the data
  stl_df$zipcode <- zip
  
  return(stl_df)
}

get_STL_data_by_zip <- function(dat, zip, ...){
  # Filter the data down to only the required zip
  filtered_dat <- dat %>% 
    filter(zipcode == zip) %>% 
    arrange(date) 
  
  # For each variable create a time series
  indices <- c("year", "month", "zipcode", "date")
  var_list <- c("zhvi", "MRP_1Br", "MRP_2Br", "MRP_3Br",
                "MRP_4Br", "MRP_5Br", "MRP_AH", "MRP_CC",
                "MRP_DT", "pickups_day", "dropoffs_day",
                "n_issued_day", "n_expired_day")   
  
  for(variable in var_list){
    zip_ts <- create_time_series_by_variable(filtered_dat, variable, ...)
    if (is.null(zip_ts)) next
    stl_df <- get_STL_df_by_variable(zip_ts, variable, zip)
    if (is.null(stl_df)) next
    dat <- insert_STL_data_into_df(stl_df, dat, zip)
  }
  return(dat)
  
}

insert_STL_data_into_df <- function(stl_df, dat, single_zip){
  # replace the values in the main data frame with the new values
  conditional <- which(dat$date %in% stl_df$date &
                         dat$zipcode == single_zip)
  stl_df <- arrange(stl_df, month, year)
  
  if (nrow(stl_df) == nrow(dat[conditional, colnames(stl_df)])) {
    dat[conditional, colnames(stl_df)] <- stl_df
  }
  
  
  return(dat)
}











