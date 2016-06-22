# Lets play!

# Builind a model with just liquor data??
test <- filter(small_join, !is.na(zhvi), !is.na(n_issued), !is.na(n_expired)) %>% select(zipcode, year, month, zhvi, n_issued, n_expired) 
test <- test[-c(2018, 8714, 8818),]
mini_model <- lm(zhvi ~ n_issued + n_expired, data=test)
summary(mini_model)
plot(mini_model)

 
library(ggplot2)
ggplot(data=test2, aes(x=zhvi, y=..density..)) + geom_histogram(bins=100) + geom_density() 

#lets chop it!
test2 <- filter(test, zhvi < 1.2E6, n_expired < 20, n_issued < 40)
test2 <- test2[-4291,]
mini_model2 <- lm(zhvi ~ n_issued + n_expired, data=test2)
summary(mini_model2)
plot(mini_model2)

ggplot(data=test2, aes(x=zhvi, y=n_issued)) + geom_jitter() + geom_smooth()
ggplot(data=test2, aes(x=zhvi, y=n_expired)) + geom_jitter() + geom_smooth()
