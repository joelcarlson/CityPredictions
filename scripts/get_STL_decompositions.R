
source("scripts/STL_decomposition_functions.R")

#load the data
dat <- read.csv("data/all_data_processed.csv")
dat$date <- as.Date(dat$date)

#For each zip:
# - Fit am STL model on data up to 2014/6
# - From the STL extract the trends for the MRPs of interest, and the features (liquor and taxis)
# - calculate the month over month changes in the trend data

load("data/NY_Info/NY_zips.RData")

# Create a series of new columns to add data into
cols_not_used <- c("year", "month", "zipcode", "date", "days_in_month", "pickup", "dropoff", "n_issued", "n_expired")
stl_cols <- c(paste0(colnames(dat)[!colnames(dat) %in% cols_not_used] , "_seasonal"),
              paste0(colnames(dat)[!colnames(dat) %in% cols_not_used] , "_trend"),
              paste0(colnames(dat)[!colnames(dat) %in% cols_not_used] , "_remainder"))  

dat[,stl_cols] <- NA 

for(zip in unique(dat$zipcode)){
  message(zip)
  dat <- get_STL_data_by_zip(dat, zip)
}

write.csv(dat, "data/all_data_with_trends.csv", row.names=FALSE)