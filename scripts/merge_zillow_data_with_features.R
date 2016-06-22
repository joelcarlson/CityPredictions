library(dplyr); library(reshape2)

# ZHVI data for all homes
Zip_Zhvi_AllHomes <- read.csv("data/Zillow/Zip/Zip_Zhvi_AllHomes.csv")

# 

feature_data <- read.csv('data/Features/feature_data.csv')

dat <- filter(Zip_Zhvi_AllHomes, City == "New York", State =="NY")
dat <- select(dat, -RegionID, -City, -State, -Metro, -CountyName, -SizeRank)
dat_m <- melt(dat, id.vars=c("RegionName"))

# Make more date-ey, paste on a day to make it unambiguous
dat_m$variable <- sapply(as.character(dat_m$variable),
                         function(x) paste(substr(x, 2, nchar(x)),".01",
                                           sep="") )
dat_m$variable <- as.Date(dat_m$variable, format="%Y.%m.%d")
dat_m$year <- year(dat_m$variable)
dat_m$month <- month(dat_m$variable)
dat_m <- select(dat_m, -variable)
colnames(dat_m) <- c("zipcode", "zhvi", "year", "month")

#feature_data <- left_join(dat_m, feature_data, by=c("zipcode", "year", "month"))
feature_data <- full_join(dat_m, feature_data, by=c("zipcode", "year", "month"))

#==================
# Two different potential prediction targets - increase in year over year rental price
# or difference between median listing and sale price.

#Zillow filtering function for simplifying reading
read_zillow_data <- function(file_path, val_name, RegionID=FALSE){
  dat <- read.csv(file_path)
  if(RegionID){
    dat <- filter(dat, City == "New York", State =="NY") %>% select(-RegionID, -City, -State, -Metro, -CountyName, -SizeRank)
  } else{
    dat <- filter(dat, City == "New York", State =="NY") %>% select(-City, -State, -Metro, -CountyName, -SizeRank)  
  }
  
  dat <- melt(dat, id.vars=c("RegionName"))
  
  dat$variable <- sapply(as.character(dat$variable),
                           function(x) paste(substr(x, 2, nchar(x)),".01",
                                             sep="") )
  dat$variable <- as.Date(dat$variable, format="%Y.%m.%d")
  
  dat$year <- year(dat$variable)
  dat$month <- month(dat$variable)
  
  dat <- select(dat, -variable)
  colnames(dat) <- c("zipcode", val_name, "year", "month")

  return(dat)
}



#List prices MLP = MedianListingPrice, Br=bedroom, AH = AllHomes, CC = CondoCoop, DT = DuplexTriplex
MLP_1Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_1Bedroom.csv", "MLP_1Br")
MLP_2Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_2Bedroom.csv", "MLP_2Br")
MLP_3Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_3Bedroom.csv", "MLP_3Br")
MLP_4Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_4Bedroom.csv", "MLP_4Br")
MLP_5Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_5BedroomOrMore.csv", "MLP_5Br")
MLP_AH <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_AllHomes.csv", "MLP_AH")
MLP_CC <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_CondoCoop.csv", "MLP_CC")
MLP_DT <- read_zillow_data("data/Zillow/Zip/Zip_MedianListingPrice_DuplexTriplex.csv", "MLP_DT")

#Sale Prices
MSP_AH <- read_zillow_data("data/Zillow/Zip/Zip_MedianSoldPrice_AllHomes.csv", "MSP_AH", RegionID=TRUE)

# Rentals
MRP_1Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_1Bedroom.csv", "MRP_1Br")
MRP_2Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_2Bedroom.csv", "MRP_2Br")
MRP_3Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_3Bedroom.csv", "MRP_3Br")
MRP_4Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_4Bedroom.csv", "MRP_4Br")
MRP_5Br <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_5BedroomOrMore.csv", "MRP_5Br")
MRP_AH <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_AllHomes.csv", "MRP_AH")
MRP_CC <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_CondoCoop.csv", "MRP_CC")
MRP_DT <- read_zillow_data("data/Zillow/Zip/Zip_MedianRentalPrice_DuplexTriplex.csv", "MRP_DT")

