library(data.table)
library(sparklyr)
library(dplyr)
library(readr)
# spark_install(version= "2.0.0")

train_file <- "train-0.01m.csv"
test_file  <- "test.csv"
data_folder <-  "~/datasets_v/flights/"

# Read data
d_train <- fread(input = paste0(data_folder, train_file))
d_test <- fread(input = paste0(data_folder, test_file))

# Connect to the cluster
config <- spark_config()
config$`sparklyr.shell.driver-memory` <- "55G"
config$`sparklyr.shell.executor-memory` <- "55G"
sc <- spark_connect(master = "local", config=config)

#dummies
X_train_test <-  model.matrix(Speed ~ ., data = rbind(d_train, d_test))
X_train <- X_train_test[1:nrow(d_train),]
X_test <- X_train_test[(nrow(d_train)+1):(nrow(d_train)+nrow(d_test)),]

X_train$Speed <- d_train$Speed
X_test$Speed <- d_test$Speed


#Copy the data from R to the cluster
#Alternatively we should user spark_read functions
train <- copy_to(sc, X_train, "train")
test <- copy_to(sc, X_test, "test")

#Train model
system.time(
  fit <- train %>% 
    ml_linear_regression(Speed ~ .,
                         lambda = 0.3) #Regularization required
) -> time_to_train

cat("Training time:", fill = T)
print(time_to_train)

#Predict test and evaluate
system.time(
  pred <- sdf_predict(fit, test) 
) -> time_to_predict

cat("Prediction time:", fill = T)
print(time_to_predict)

system.time(
  pred <- collect(pred) #Brings data from remote to data.frame
) -> time_to_collect

cat("Collection time:", fill = T)
print(time_to_collect)

