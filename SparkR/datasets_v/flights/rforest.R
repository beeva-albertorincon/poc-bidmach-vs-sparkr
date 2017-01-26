#-----------------------------------------------------------------------------
# CONFIG

train_file <- "train-0.01m.csv"
test_file  <- "test.csv"
val_file   <- "valid.csv"
data_folder <- "~/datasets_v/flights/"

#-----------------------------------------------------------------------------

library(sparklyr)
library(data.table)
library(dplyr)
library(hydroGOF)
library(magrittr)
library(readr)

# Read data
d_train <- fread(paste0(data_folder, train_file))
d_test <- fread(paste0(data_folder, train_file))

#dummies
X_train_test <-  model.matrix(Speed ~ ., data = rbind(d_train, d_test))
X_train <- X_train_test[1:nrow(d_train),]
X_test <- X_train_test[(nrow(d_train)+1):(nrow(d_train)+nrow(d_test)),]

X_train$Speed <- d_train$Speed
X_test$Speed <- d_test$Speed


# Connect to Spark
config <- spark_config()
config$`sparklyr.shell.driver-memory` <- "5G"
config$`sparklyr.shell.executor-memory` <- "5G"
sc <- spark_connect(master = "local", config=config)


# Copy data to Spark
system.time({
  
  flight_train_tbl <- copy_to(sc, X_train, "flights_train")
  flight_test_tbl  <- copy_to(sc, X_test, "flights_test")
  
}) -> time_to_copy

cat("Time to copy to Spark:", fill = T)
print(time_to_copy)


# Fit a random forest model
system.time({
  flight_train_tbl %>% 
    ml_random_forest(Speed ~ ., type = "regression", num.trees = 100) -> 
    rf_model
}) -> time_to_train

cat("Training time:", fill = T)
print(time_to_train)

# Training time:
#   user  system elapsed 
# 3.472   0.176  25.821 

# Most important features?
# rf_model$features %>% 
#   extract(order(rf_model$feature.importances, decreasing = T)) %>% head()
## Distance and UniqueCarrier


# Predict test
system.time({
  sdf_predict(rf_model, flight_test_tbl) %>% 
    select(prediction) -> pred
}) -> time_to_predict

cat("Prediction time:", fill = T)
print(time_to_predict)


# Collect results
system.time({
  pred <- collect(pred)
}) -> time_to_collect

cat("Collection time:", fill = T)
print(time_to_collect)

# Prediction time:
#   user  system elapsed 
# 2.656   0.096  10.001 
