library(dplyr)

# This script reads in the liquor data from ny data.gov and gets the median duration
# for each class of license
dat <- read.csv('data/Liquor/Liquor_Authority_Quarterly_List_of_Active_Licenses.csv', stringsAsFactors=FALSE)

# Convert columns to datetime format, get difference
dat$V13 <- as.Date(dat$License.Effective.Date, format="%m/%d/%Y")
dat$V14 <- as.Date(dat$License.Expiration.Date, format="%m/%d/%Y")
dat$V15 <- as.numeric(dat$V14 - dat$V13)

# Get median to find how long license classes last until expiration
license_lengths <- dat %>% group_by(License.Class.Code)  %>% summarize(median_duration=median(V15, na.rm=TRUE), sd = sd(V15, na.rm=TRUE), n())

write.csv(license_lengths, "data/Liquor/license_class_duration.csv")