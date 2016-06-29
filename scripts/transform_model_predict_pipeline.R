# Here we will create the full prediction/validation pipeline. 
# The steps:
#  1. Split data into training and test data based on date
#  2. Fit STL curves by zipcode on the training and the training+test data separately
#  3. Create lagged features 
#  4. Train models on the training data. Models include:
#    a. Random forest with all features
#    b. Random forest without Liquor and Taxi data
#    c. Naive model (i.e. mean of training data)
#  5. Make predictions on testing data
library(dplyr); library(randomForest)

source("scripts/STL_decomposition_functions.R")
#load and prepare the data
load_and_prepare_data <- function(file_path = "data/all_data_processed.csv"){
  dat <- read.csv(file_path)
  dat$date <- as.Date(dat$date)
  
  # Create a series of new columns to add data into
  cols_not_used <- c("year", "month", "zipcode",
                     "date", "days_in_month", "pickup",
                     "dropoff", "n_issued", "n_expired")
  
  stl_cols <- c(paste0(colnames(dat)[!colnames(dat) %in% cols_not_used] , "_seasonal"),
                paste0(colnames(dat)[!colnames(dat) %in% cols_not_used] , "_trend"),
                paste0(colnames(dat)[!colnames(dat) %in% cols_not_used] , "_remainder"))  
  
  dat[,stl_cols] <- NA 
  return(dat)
}

# Function to acquire STL curves given zip, and end date for training
get_STL_data_by_zip <- function(dat, target="MRP_1Br", single_zip){
  
  # For each variable create a time series
  indices <- c("year", "month", "zipcode", "date")
  var_list <- c(target, "pickups_day", "dropoffs_day",
                "n_issued_day", "n_expired_day")
  
  
  # Filter the data down to only the required zip
  filtered_dat <- dat %>% 
    filter(zipcode == single_zip) %>% 
    arrange(date) %>% 
    select(one_of(indices), one_of(var_list))
  
  end_date <- c(filtered_dat$year[nrow(filtered_dat)], filtered_dat$month[nrow(filtered_dat)])
  
  for(variable in var_list){
    zip_ts <- create_time_series_by_variable(filtered_dat, variable, end_date)
    if (is.null(zip_ts)) next
    stl_df <- get_STL_df_by_variable(zip_ts, variable, single_zip)
    if (is.null(stl_df)) next
    dat <- insert_STL_data_into_df(stl_df, dat=dat, single_zip)
  }
  return(dat)
  
}

# Function to split data into training and test sets based on end date for training
split_data_into_train_test_sets <- function(dat, train_end_date = c(2014,6)){
  date_str <- paste0(train_end_date[1], '-', train_end_date[2],'-15')
  training <- filter(dat, date <= date_str)
  # testing remains all of dat as we wish to predict the trend that is produced.
  # The trend is to be informed by historical values 
  # Predictions are statistically valid as long as training data does not
  # have access to testing data
  testing <- dat 
  return(list("training"=training, "testing"=testing, "train_end_date"=date_str))
}

# Function to extract STL curves for training and testing given a target variable
get_STL_curves <- function(train_test_list, variable="MRP_1Br", zips){
  training <- train_test_list$training
  testing <- train_test_list$testing
  
  for(each_zip in zips){
    message(each_zip)
    training <- get_STL_data_by_zip(dat=training, variable, each_zip)
    testing <- get_STL_data_by_zip(dat=testing, variable, each_zip)
  }
  
  return(list("training"=training, "testing"=testing, "train_end_date"=train_test_list['train_end_date']))
}

# Function to create lagged features in training and testing sets
create_lagged_features <- function(train_test_STL_list, variable="MRP_1Br"){
  variable_trend <- paste0(variable, "_trend")
  train_test_STL_lagged <- list()
  for(item in c("training", "testing")){
    dat <- train_test_STL_list[[item]] %>% arrange(zipcode, date) %>% 
      
      # Create the Month over Month growth columns
      # the bare name is the trended growth, the _raw column
      # utilizes the raw data
      mutate_(.dots = setNames(list(interp(~ val/lag(val),
                                             val=as.name(variable_trend))),
                               paste0(variable, "_MoM"))) %>%
      mutate_(.dots = setNames(list(interp(~ val/lag(val),
                                           val=as.name(variable))),
                               paste0(variable, "_raw_MoM"))) %>%
                
      mutate(n_issued_MoM = n_issued_day_trend / lag(n_issued_day_trend),
             n_expired_MoM = n_expired_day_trend / lag(n_expired_day_trend),
             pickups_MoM = pickups_day_trend / lag(pickups_day_trend),
             dropoffs_MoM = dropoffs_day_trend / lag(dropoffs_day_trend))
    
    # Create features lagged by up to 12 months
    lags <- c(1:12)
    variable_MoM <- paste0(variable, "_MoM")
    for(n_lags in lags) {
      #Highly unfortunate syntax for programmatically creating lagged features
      dat <- dat %>% arrange(zipcode, date) %>% group_by(zipcode) %>% 
        mutate_(.dots = setNames(list(interp(~ lag(n_issued_MoM, n_lags))),
                                 paste0("n_issued_MoM_", n_lags))) %>%
        mutate_(.dots = setNames(list(interp(~ lag(n_expired_MoM, n_lags))),
                                 paste0("n_expired_MoM_", n_lags))) %>% 
        mutate_(.dots = setNames(list(interp(~ lag(pickups_MoM, n_lags))),
                                 paste0("pickups_MoM_", n_lags))) %>% 
        mutate_(.dots = setNames(list(interp(~ lag(dropoffs_MoM, n_lags))),
                                 paste0("dropoffs_MoM_", n_lags))) %>% 
        
        mutate_(.dots = setNames(list(interp(~ lag(val, n_lags), val=as.name(variable_MoM))),
                                 paste0(variable_MoM, "_", n_lags)))
      
    }     
    
    train_test_STL_lagged[[item]] <- dat
  }
  train_test_STL_lagged['train_end_date'] <- train_test_STL_list[["train_end_date"]]
  return(train_test_STL_lagged)
}

train_test_naive_model <- function(train_test_STL_lagged_list, target = "MRP_1Br_MoM"){

  # The naive model predicts the mean of the training set target variable
  predictions <- mean(train_test_STL_lagged_list[['training']][[target]], na.rm=TRUE)
  train_test_STL_lagged_list[['testing']]$naive_preds <- predictions
  return(train_test_STL_lagged_list)
}

train_test_rf_model <- function(train_test_STL_lagged_list, target = "MRP_1Br_MoM", full=TRUE){
  # The full rf model builds a random forest using lagged target features and L + T data
  # The future predictions of the model are limited by the earliest data included in the model
  # i.e. if data on a 3 month lag is included, then the furthest the model can predict is 
  # 3 months into the future
  
  # Model parameters tuned in scripts/gridsearch_rf_model_parameters.R
  
  set.seed(111)
  t3 <- paste0(target, "_3")
  t4 <- paste0(target, "_4")
  t5 <- paste0(target, "_5")
  t6 <- paste0(target, "_6")
  t7 <- paste0(target, "_7")
  t8 <- paste0(target, "_8")
  t9 <- paste0(target, "_9")
  t10 <- paste0(target, "_10")
  t11 <- paste0(target, "_11")
  t12 <- paste0(target, "_12")
  
  model_form <- paste(target, "~", paste(t3,t4,t5,t6,t7,t8,t9,t10,t11,t12, sep=" + "))
  mtry <- 10
  ntree <- 500

  #model_form <- paste0(target, " ~ n_issued_MoM_6 + n_expired_MoM_6 + pickups_MoM_6 + dropoffs_MoM_6 + ",
  #                       "n_issued_MoM_12 + n_expired_MoM_12 + pickups_MoM_12 + dropoffs_MoM_12")
                       
  #if(full) model_form <- paste0(model_form, " + ", t3, " + ", t6, " + ", t12)
  if(full){
    model_form <- paste0(model_form, " + ",
                         paste0(c("n_issued_MoM_",
                                  "n_expired_MoM_",
                                  "pickups_MoM_",
                                  "dropoffs_MoM_"),
                                rep(c(1:12),4), collapse=" + "), collapse=" + ")
    mtry <- 15
    ntree <- 1000
  }
  
  #message(model_form)                    
  full_rf_model <- randomForest(as.formula(model_form),
                           data=train_test_STL_lagged_list[['training']],
                           na.action = na.omit,
                           mtry = mtry,
                           ntree=ntree,
                           importance=TRUE,
                           nodesize=10)
  
  #message("RF Model Trained")
  #new_rf <<- full_rf_model
  #fail_data <<- train_test_STL_lagged_list
  predictions <- predict(full_rf_model, train_test_STL_lagged_list[['testing']])
  
  #message("Made predictions")
  if(full){
    #message("Checked full")
    train_test_STL_lagged_list[['testing']]$full_rf_preds <- predictions
  } else {
    #message("checked full")
    train_test_STL_lagged_list[['testing']]$rf_preds <- predictions
  }
  
  #message("returning data?")
  return(train_test_STL_lagged_list)
}

# All together now!
prediction_pipeline <- function(data_path='data/all_data_processed.csv',
                         variable="MRP_1Br", train_end_date=c(2014,6), zipcodes=c(11237, 10035)){
  ## This is where things work!
  prepped_dat <- load_and_prepare_data(file_path = data_path)
  #  1. Split data into training and test data based on date
  train_test <- split_data_into_train_test_sets(dat=prepped_dat, train_end_date)
  #  2. Fit STL curves by zipcode on the training and the training+test data separately
  train_test_STL <- get_STL_curves(train_test, variable=variable, zips=zipcodes)
  #  3. Create lagged features 
  train_test_STL_lagged <- create_lagged_features(train_test_STL, variable=variable)
  #  4. Train models on the training data. Models include:
  #    a. Random forest with all features
  #    b. Random forest without Liquor and Taxi data
  #    c. Naive model (i.e. mean of training data)
  target <- paste0(variable, "_MoM")
  
  train_test_STL_lagged <- train_test_naive_model(train_test_STL_lagged, target=target )
  train_test_STL_lagged <- train_test_rf_model(train_test_STL_lagged, target=target, full=TRUE)
  train_test_STL_lagged <- train_test_rf_model(train_test_STL_lagged, target=target, full=FALSE)
  
  train_end_date <- train_test_STL_lagged[['train_end_date']]
  train_test_STL_lagged[['testing']]$train_end_date <- train_end_date 
  train_test_STL_lagged[['training']]$train_end_date <- train_end_date
               #$train_end_date <- train_end_date
  return(train_test_STL_lagged)
} 

