library(tidyr); library(dplyr)

# unite files
liquor_licenses <- read.csv("data/Liquor/liquor_licenses.csv", stringsAsFactors=FALSE)
food_ins_criticalFlags <- read.csv("data/FoodService/food_ins_criticalFlags.csv", stringsAsFactors=FALSE)
food_ins_grades <- read.csv("data/FoodService/food_ins_grades.csv", stringsAsFactors=FALSE)

food_ins_criticalFlags <- spread(food_ins_criticalFlags, CRITICAL.FLAG, value=CRITICAL.FLAG.1)
food_ins_grades <- spread(food_ins_grades, GRADE, value=GRADE.1)

food_ins <- full_join(food_ins_grades, food_ins_criticalFlags, by=c("ZIPCODE", "Year", "Month"))
colnames(food_ins) <- c("zipcode", "year", "month", "gradeA", "gradeB", "gradeC", "noGrade", "gradeP", "gradeZ", "yesCritical", "NACritical", "notCritical" )

feature_data <- full_join(liquor_licenses, food_ins, by=c("zipcode", "year", "month"))

write.csv(feature_data, "data/Features/feature_data.csv", row.names=FALSE)