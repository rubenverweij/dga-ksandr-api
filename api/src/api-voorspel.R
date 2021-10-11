library(xgboost)
library(dplyr)

source("api-voorspelling_2_numeric.R")
source("../config/model_constanten.R")


controleer_features <- function(df){
  # functie zorgt ervoor dat de features en volgorde
  # overeenkomen met wat de modellen verwachten
  
  df <- as.data.frame(df)
  columns_to_be_added <- features_model[!features_model %in% colnames(df)]
  if (length(columns_to_be_added) > 0){
    for (column in columns_to_be_added){
      df[column] <- 0
    }
  }

  columns_to_be_removed <- colnames(df)[!colnames(df) %in% features_model]
  if (length(columns_to_be_removed) > 0){
    df <- df %>% select(-columns_to_be_removed)
  }
  
  df <- df[, features_model]
  return(as.matrix(df))
}

voorspel <- function(data_xgboost, Y){
  mPredict_data <- data_xgboost$mTest_data
  #data_xgboost <- data_xgboost[[1]]
  model_name <- paste0('../models/',Y,'.model')
  bst <- xgb.load(model_name)

  # controleer features
  mPredict_data <- controleer_features(mPredict_data)
  forecast <- voorspelling_2_numeric(predict(bst, mPredict_data), Y = Y)
  return(list(Model = bst, voorspelling = forecast))
}
