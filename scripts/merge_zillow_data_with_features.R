library(dplyr); library(reshape2)

Zip_Zhvi_AllHomes <- read.csv("...")
feature_data <- read.csv('...')

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

small_join <- left_join(dat_m, feature_data, by=c("zipcode", "year", "month"))
big_join <- full_join(dat_m, feature_data, by=c("zipcode", "year", "month"))
