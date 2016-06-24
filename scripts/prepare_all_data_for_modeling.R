library(dplyr); library(tidyr); library(stringr)

dat <- read.csv('data/all_data.csv', stringsAsFactors = FALSE)
dat$date <- as.Date(dat$date)

#We will restrict analysis to data from 2010 to 2016
# Sadly the data from 2015 is incomplete and unusable at this point
dat <- filter(dat, date > "2010-12-15", date < "2015-01-01")

# We will also not use the restaurant data for now
dat <- select(dat, zipcode, date, year, month, zhvi, contains("MRP"), n_issued, n_expired, pickup, dropoff)

# Add all dates and zipcodes as indices
dat_index <- expand.grid("year"=c(2011:2014), "month"=c(1:12), "zipcode"=unique(dat$zipcode))
dat <- full_join(dat_index, dat, by=c("zipcode", "year", "month"))

# Fix the bad dates
dat$date <- paste0(dat$year, '/', str_pad(dat$month, 2, side='left', '0'), '/15')
dat$date <- as.Date(dat$date, format="%Y/%m/%d")

average_month_before_after <- function(bad_year, bad_month, zipcode){
  after = dat[dat$year == bad_year & dat$month == bad_month + 1 & dat$zipcode == zipcode, c("pickup", "dropoff")] 
  before = dat[dat$year == bad_year & dat$month == bad_month - 1 & dat$zipcode == zipcode, c("pickup", "dropoff")]
  
  # Modify the dataframe outside of the function....
  dat[dat$year == bad_year & dat$month == bad_month & dat$zipcode == zipcode, "pickup"] <<- (after$pickup + before$pickup)/2
  dat[dat$year == bad_year & dat$month == bad_month & dat$zipcode == zipcode, "dropoff"] <<- (after$dropoff + before$dropoff)/2
}

for(zip in c(unique(dat$zipcode))){
  average_month_before_after(2011,2,zip)
  average_month_before_after(2011,4,zip)
  average_month_before_after(2012,7,zip) 
  
  # Do 12/2011 ...
  after = dat[dat$year == 2012 & dat$month == 1 & dat$zipcode == zip, c("pickup", "dropoff")] 
  before = dat[dat$year == 2011 & dat$month == 11 & dat$zipcode == zip, c("pickup", "dropoff")]
  
  # Modify the dataframe outside of the function....
  dat[dat$year == 2011 & dat$month == 12 & dat$zipcode == zip, "pickup"] <- (after$pickup + before$pickup)/2
  dat[dat$year == 2011 & dat$month == 12 & dat$zipcode == zip, "dropoff"] <- (after$dropoff + before$dropoff)/2
}

dat[which(is.na(dat$n_issued)), "n_issued"] <- 0
dat[which(is.na(dat$n_expired)), "n_expired"] <- 0
dat[which(is.na(dat$pickup)), "pickup"] <- 0
dat[which(is.na(dat$dropoff)), "dropoff"] <- 0

# Normalize pickups and dropoffs by number of days in the month
monthdays <- data.frame("month"=c(1:12), "days_in_month"=c(31,28,31,30,31,30,31,31,30,31,30,31))
dat <- left_join(dat, monthdays, by="month")
dat <- dat %>% mutate(pickups_day = pickup/days_in_month,
                      dropoffs_day = dropoff/days_in_month,
                      n_issued_day = n_issued/days_in_month,
                      n_expired_day = n_expired/days_in_month)

write.csv(dat, "data/all_data_processed.csv", row.names=FALSE)
