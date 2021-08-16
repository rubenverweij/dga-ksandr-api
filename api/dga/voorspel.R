library(xgboost)

source("voorspelling_2_numeric.R")

voorspel <- function(data_xgboost, Y){
  mPredict_data <- data_xgboost$mTest_data
  data_xgboost <- data_xgboost[[1]]
  model_name <- paste0('../models/',Y,'.model')
  bst <- xgb.load(model_name)
  forecast <- voorspelling_2_numeric(predict(bst,mPredict_data), Y = Y)
  return(list(Model = bst, voorspelling = forecast))
}