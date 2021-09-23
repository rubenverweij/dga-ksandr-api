source("api-xgboost_data.R")
source("api-voorspel.R")

voorspel_dga <- function(data) {
  # Create xgboost type matrices
  mData_xg_h2 <- xgboost_data(data, Y = 'H2')
  mData_xg_ch4 <- xgboost_data(data, Y = 'CH4')
  mData_xg_c2h6 <- xgboost_data(data, Y = 'C2H6')
  mData_xg_c2h4 <- xgboost_data(data, Y = 'C2H4')
  mData_xg_c2h2 <- xgboost_data(data, Y = 'C2H2')
  mData_xg_risico <- xgboost_data(data, Y = 'duval')
  # Create forecasts
  vH2 <- voorspel(mData_xg_h2, Y = 'H2')
  vCH4 <- voorspel(mData_xg_ch4, Y = 'CH4')
  vC2H6 <- voorspel(mData_xg_c2h6, Y = 'C2H6')
  vC2H4 <- voorspel(mData_xg_c2h4, Y = 'C2H4')
  vC2H2 <- voorspel(mData_xg_c2h2, Y = 'C2H2')
  
  # Risico model
  model_name <- paste0('../models/duval.model')
  bst <- xgb.load(model_name)
  forecast_categorical <- predict(bst, mData_xg_risico$mTest_data)
  # Index
  indec <- mData_xg_h2$UN
  
  # Return output with UN
  mForecast <-
    cbind(
      mData_xg_h2$Datum,
      mData_xg_h2$UN,
      vH2$voorspelling,
      vCH4$voorspelling,
      vC2H6$voorspelling,
      vC2H4$voorspelling,
      vC2H2$voorspelling,
      round(forecast_categorical * 100, 2)
    )
  colnames(mForecast) <-
    c('Datum', 'UN', 'H2', 'CH4', 'C2H6', 'C2H4', 'C2H2', 'Risico')
  mForecast_sort <- as_tibble(mForecast)
  mForecast_sort <- as.data.table(mForecast_sort %>% arrange(UN))
  
  mTest_sample <-
    data.frame(mForecast_sort[mForecast_sort[, .I[Datum == max(Datum)], by =
                                               UN]$V1])
  mTest_sample[, c('H2', 'CH4', 'C2H6', 'C2H4', 'C2H2', 'Risico')] <-
    as.numeric(as.matrix(mTest_sample[, c('H2', 'CH4', 'C2H6', 'C2H4', 'C2H2', 'Risico')]))
  return(list(mForecast_sample = mTest_sample[, c('UN', 'H2', 'CH4', 'C2H6', 'C2H4', 'C2H2', 'Risico')]))
  
}