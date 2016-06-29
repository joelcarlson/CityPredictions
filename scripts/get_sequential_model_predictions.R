source("scripts/transform_model_predict_pipeline.R")
load("data/NY_Info/NY_zips.RData")
library(lubridate)
date_lst <- seq.Date(from=as.Date("2013-01-15"),
                     to=as.Date("2014-12-15"),
                     by="month")

#for(variable in c("MRP_1Br", "MRP_2Br", "MRP_3Br")){
for(variable in c( "MRP_2Br", "MRP_3Br")){
for(date in as.character(date_lst)){

      date_components <- c(year(date), month(date))
      message(date)
      dat <- prediction_pipeline(data_path='data/all_data_processed.csv',
                                 variable=variable,
                                 train_end_date=date_components,
                                 zipcodes=NY_zips)
      
      message(paste("Variable: ",variable, " | date: ", date))
      testing <- dat[['testing']]
      training <- dat[['training']]
      
      write.csv(training, paste0("data/temp/", date, "_", variable, "_training.csv"), row.names=FALSE)
      write.csv(testing, paste0("data/temp/", date, "_", variable, "_testing.csv"), row.names=FALSE)
                          
}}