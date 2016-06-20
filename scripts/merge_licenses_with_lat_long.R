library(zipcode); library(dplyr); library(stringr)
data(zipcode)

gov_data <- read.csv("data/Liquor/intermediate/Liquor_Authority_Quarterly_List_of_Active_Licenses.csv", stringsAsFactors=FALSE)
All_Licenses_v02 <- read.csv("data/Liquor/intermediate/All_Licenses_v02.csv", stringsAsFactors=FALSE)
zipcode$zipcode <- as.integer(zipcode$zip)

All_licenses_v03 <- left_join(All_Licenses_v02, zipcode, by='zipcode')

# Extract the serial number with fancy regex
All_licenses_v03 <- mutate(All_licenses_v03,
                           "License.Serial.Number" = as.integer(str_extract(link,
                                                  pattern="(?<=serialNumber=)(.*)(?=&)")))

# We can utilize the government data by joining it on serial number
All_licenses_v03 <- left_join(All_licenses_v03, select(gov_data, License.Serial.Number, Latitude, Longitude), by='License.Serial.Number')

# If the gov data has lat and long, take them, otherwise us the zip
All_licenses_v03$latitude <- ifelse(is.na(All_licenses_v03$Latitude) |
                                      All_licenses_v03$Latitude < 30 | #NY lower lat
                                      All_licenses_v03$Latitude > 40.95,  #NY upper lat
                                    All_licenses_v03$latitude,
                                    All_licenses_v03$Latitude)
All_licenses_v03$longitude <- ifelse(is.na(All_licenses_v03$Longitude) | 
                                       All_licenses_v03$Longitude > -73.5 | #NY upper long
                                       All_licenses_v03$Longitude < -75,  #NY lower long
                                     All_licenses_v03$longitude,
                                     All_licenses_v03$Longitude)

# Drop the extra columns and call it a day!
All_licenses_v03 <- select(All_licenses_v03, -Latitude, -Longitude, -License.Serial.Number)

write.csv(All_licenses_v03, "data/Liquor/intermediate/All_Licenses_v03.csv", row.names=FALSE)
