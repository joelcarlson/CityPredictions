# Scoring function

# There are a couple of ways to go about scoring the predictive ability of an algorithm
# This approach will take a successful forecast as one that, in the month after the projection
# the model correctly predicted an increase or decrease in the parameter of interest (prediction target)
library(forecast); library(dplyr)
dat <- read.csv("../data/all_data_processed.csv")
load("../data/NY_Info/brooklyn_zips.RData")
dat <- filter(dat, zipcode %in% brooklyn)


# Prediction Pipeline:

# 1.Select zipcode and required MRP
# 2.Filter data 
#  - by zip
#  - remove NAs in prediction target
#  - Arrange by year and month
#  - convert to time series object
# 3. Split into training and test data (test on 20% ?)
#
# 4. Make predictions
#  - Decompose time series
#  - forecast

# 1. Select zipcode and required MRP
set.seed(11)
zip <- sample(brooklyn,1)
target = "MRP_1Br"

# 2. Filter data
zip_filter <- paste0("!is.na(",target,")", "& zipcode == ", zip )
zip_dat <- dat %>%
  filter_(zip_filter) %>%
  arrange(year, month) 

train_rows <- floor(nrow(zip_dat)*0.8)
training <- zip_dat[1:train_rows,]
testing <- zip_dat[(1+train_rows):nrow(zip_dat),]

# 3. Split into training and test data (test on 20% ?)
training_ts <- ts(training, deltat=1/12, start=c(training$year[1], training$month[1]))
testing_ts <- ts(testing, deltat=1/12, start=c(testing$year[1], testing$month[1]))

# 4. Make Predictions
# Decompose
zip_decomp <- stl(training_ts[,target], s.window=12)

# Add components to data
#cols <- colnames(training_ts)
#training_ts <- cbind(training_ts,
#                "seasonal" = zip_decomp$time.series[,'seasonal'],
#                "trend" = zip_decomp$time.series[,'trend'])
#colnames(training_ts) <- c(cols, c("seasonal", "trend"))

zip_lm <- tslm(training_ts[,'MRP_1Br'] ~ season + trend, data=training_ts)
CV(zip_lm)

+ n_issued_day + n_expired_day + pickups_day + dropoffs_day

plot(forecast(zip_lm, h=20))

#fcast <- forecast(zip_decomp)
#plot(fcast)

y <- ts(rnorm(120,0,3) + 1:120 + 20*sin(2*pi*(1:120)/12), frequency=12)
fit <- tslm(y ~ trend + season)
plot(forecast(fit, h=20))


tz_lm_preds <- predict(tz_lm, window(top_zip, start=2013.5))
tz_lm_preds <- ts(tz_lm_preds, deltat=1/12, start=c(2013.5))

plot(top_zip[,'MRP_1Br'], col="blue")
lines(top_zip2[,'MRP_1Br'], col="black", lwd=1.5)
lines(tz_lm_preds, col="red")



prediction_acc <- function(model, )
  
  