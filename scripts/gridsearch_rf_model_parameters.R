source("scripts/transform_model_predict_pipeline.R")
library(reshape2); library(ggplot2); library(dplyr); library(lazyeval)
load('data/NY_Info/brooklyn_zips.RData')

train_end_date <- c(2014,1)
prepped_dat <- load_and_prepare_data()

#  1. Split data into training and test data based on date
train_test <- split_data_into_train_test_sets(dat=prepped_dat, train_end_date)
#  2. Fit STL curves by zipcode on the training and the training+test data separately
train_test_STL <- get_STL_curves(train_test, variable="MRP_1Br", zips=brooklyn)
#  3. Create lagged features 
train_test_STL_lagged <- create_lagged_features(train_test_STL, variable="MRP_1Br")
#  4. Train models on the training data. Models include:
#    a. Random forest with all features
#    b. Random forest without Liquor and Taxi data
#    c. Naive model (i.e. mean of training data)

target <- paste0("MRP_1Br", "_MoM")

train_test_gs <- function(train_test_STL_lagged_list, target = "MRP_1Br_MoM", full=TRUE, mtry=10, ntree=100, node=5){
  # The full rf model builds a random forest using lagged target features and L + T data
  # The future predictions of the model are limited by the earliest data included in the model
  # i.e. if data on a 3 month lag is included, then the furthest the model can predict is 
  # 3 months into the future
  
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
  }
  
  #message(model_form)                    
  full_rf_model <- randomForest(as.formula(model_form),
                                data=train_test_STL_lagged_list[['training']],
                                na.action = na.omit,
                                mtry = mtry,
                                ntree=ntree,
                                importance=TRUE,
                                nodesize=node)
  
  #message("RF Model Trained")
  #new_rf <<- full_rf_model
  #fail_data <<- train_test_STL_lagged_list
  testing <- train_test_STL_lagged_list[['testing']]
  end_date <- as.Date(paste0(train_end_date[1], "-", train_end_date[2], "-15"))

  testing <- filter(testing, date > end_date)
  predictions <- predict(full_rf_model, testing)
  
  #message("Made predictions")
  #if(full){
    #message("Checked full")
   # train_test_STL_lagged_list[['testing']]$full_rf_preds <- predictions
    
  #} else {
    #message("checked full")
   # train_test_STL_lagged_list[['testing']]$rf_preds <- predictions
  #}
  
  
  actual <- testing$MRP_1Br_MoM 
  
  
  message(paste("acc = ",mean((actual - predictions)^2, na.rm=TRUE),
                " | mtry = ", mtry,
                "| ntree = ", ntree,
                " | nodesize = ", node))
  #message("returning data?")
  return(list("acc"=mean((actual - predictions)^2, na.rm=TRUE), "mtry"=mtry, "ntree"= ntree,"nodesize",node, "full"=full))
}
#train_test_cv(train_test_STL_lagged)

ftc <- c(TRUE, FALSE)
mtc <- c(2,5,10)
ntc <- c(250,500,1000,2000)
nsc <- c(1,5,10)
lst <- vector("list", length(ftc)*length(mtc)*length(ntc)*length(nsc))
i <-1
for(ft in ftc){
  for(mt in mtc){
    for(nt in ntc){
      for(ns in nsc){
        lst[[i]] <- train_test_gs(train_test_STL_lagged, full=ft, mtry=mt, ntree=nt, node=ns)
        i <- i + 1
      }
    }
  }
}
gs_res <- do.call(rbind.data.frame, lst)
gs_res <- arrange(gs_res, acc)
gs_res <- gs_res[,c(1,2,3,5,6)]
colnames(gs_res) <- c("acc","mtry", "ntree", "nodesize", "full")
knitr::kable(gs_res)
write.csv(gs_res,"markdowns/gridsearch_values.csv", row.names=FALSE)
