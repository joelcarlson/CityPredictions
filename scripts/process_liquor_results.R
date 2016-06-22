library(lubridate); library(dplyr)

input_path <- "data/Liquor/intermediate/"
output_path <- "data/Liquor/"

All_Licenses_v03 <- read.csv(paste0(input_path, "All_Licenses_v03.csv"), stringsAsFactors=FALSE)

All_Licenses_v03$expiration_month <- month(as.Date(All_Licenses_v03$expiration_date))
All_Licenses_v03$expiration_year <- year(as.Date(All_Licenses_v03$expiration_date))
All_Licenses_v03$issued_month <- month(as.Date(All_Licenses_v03$issued_date))
All_Licenses_v03$issued_year <- year(as.Date(All_Licenses_v03$issued_date))

keep_cols <- c("license_status", "zipcode",
               "expiration_month","expiration_year",
               "issued_month", "issued_year")


All_Licenses_select <- All_Licenses_v03[,keep_cols]

liquor_licenses_expired <- All_Licenses_select %>% group_by(zipcode, "year"=expiration_year, "month"=expiration_month) %>% summarise(n_expired = n())
liquor_licenses_issued <- All_Licenses_select %>% group_by(zipcode, "year"=issued_year, "month"=issued_month) %>% summarise(n_issued = n())

liquor_licenses <- full_join(liquor_licenses_issued, liquor_licenses_expired, by=c("zipcode", "year", "month"))

# In this case we assume that we have complete data
# thus any missing values imply 0
liquor_licenses <- liquor_licenses[!is.na(liquor_licenses$year),]

#tiny bit of cleaning, these rows have nonsensical years
liquor_licenses[(liquor_licenses$year == 2120), "year"] <- 2020
liquor_licenses[(liquor_licenses$year == 2117), "year"] <- 2017
liquor_licenses <- liquor_licenses[-which(liquor_licenses$year == 198), ]
liquor_licenses <- liquor_licenses[-which(liquor_licenses$year == 201), ]

write.csv(liquor_licenses, paste0(output_path, "liquor_licenses.csv"), row.names=FALSE)
