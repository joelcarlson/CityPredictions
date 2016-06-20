library(dplyr)

# This script combines the license class durations with the
# extracted SLA database data
durations <- read.csv("data/Liquor/intermediate/license_class_duration.csv", stringsAsFactors=FALSE)
All_Licenses <- read.csv("data/Liquor/intermediate/All_Licenses.csv", stringsAsFactors=FALSE)

#Fix colnames to conform to All_Licenses
colnames(durations) <- c("license_type", "license_duration")
All_Licenses$expiration_date <- as.Date(All_Licenses$expiration_date, format = "%m/%d/%Y")

#Goal: Merge durations$License.Type.Code and All_Licenses$license_type
All_Licenses <- left_join(All_Licenses, durations, by='license_type')
All_Licenses$issued_date <- All_Licenses$expiration_date - All_Licenses$license_duration

write.csv(All_Licenses, "data/Liquor/intermediate/All_Licenses_v02.csv", row.names=FALSE)
