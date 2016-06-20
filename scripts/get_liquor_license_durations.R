library(dplyr)

# This script reads in the liquor data from ny data.gov and gets the median duration
# for each class of license
dat <- read.csv('data/Liquor/intermediate/Liquor_Authority_Quarterly_List_of_Active_Licenses.csv', stringsAsFactors=FALSE)

# Convert columns to datetime format, get difference
dat$V13 <- as.Date(dat$License.Effective.Date, format="%m/%d/%Y")
dat$V14 <- as.Date(dat$License.Expiration.Date, format="%m/%d/%Y")
dat$V15 <- as.numeric(dat$V14 - dat$V13)

# Get median to find how long license classes last until expiration
license_lengths <- dat %>%
  group_by(License.Type.Code) %>%
  summarize(median_duration=median(V15, na.rm=TRUE))

license_lengths$License.Type.Code <- tolower(license_lengths$License.Type.Code)

# There are 6 license types in All_Licenses that are not present in gov data, so
# here I set their values to similar class types as inferred by reading the
# SLA
extras <- data.frame(License.Type.Code=c("aw","st","vb","e","cp","fv"), median_duration=c(1095, 213, 730, 730, 730, 1094))

license_lengths <- rbind(license_lengths, extras)

write.csv(license_lengths, "data/Liquor/intermediate/license_class_duration.csv", row.names=FALSE)
