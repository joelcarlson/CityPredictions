
# Propogate the Month over Month values given a starting value
prop_MoM <- function (value, MoM_vals) 
{
  MoM_vals <- MoM_vals[-1]
  k <- length(MoM_vals)
  values <- c(value)
  if (k > 1) {
    for (i in 1:k ) {
      value <- MoM_vals[[i]]*value
      values <- c(values, value)
    }
  }
  return(values)
}

#z10035 <- filter(z10035, !is.na(MRP_1Br_trend))
#prop_MoM(z10035$MRP_1Br_trend[1], z10035$MRP_1Br_MoM)
#dat$preds <- predict(rf_model, dat)
trend_predictions <- dat %>% 
  group_by(zipcode) %>% 
  do({
    m <- filter(., !is.na(preds)) %>% 
      select(date, zipcode, MRP_1Br_trend, full_rf_preds, rf_preds, naive_preds)
    try(
      m$MRP_1Br_trend_pred <- prop_MoM(m$MRP_1Br_trend[1], m$preds),
      silent=TRUE)
    m
  })

dat <- left_join(dat, trend_predictions, by=c("date","zipcode"))