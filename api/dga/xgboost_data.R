source("set_column_types.R")

xgboost_data <- function(full_data, Y){
  
  # Variabelen =: X + Y
  variablen <- c("UN","H2","C2H6",
                 "C2H4","CH4","C2H2","CO","TDCGkleur",
                 "C3H8_propaan_ul_p_l","C3H6_propeen_ul_p_l",
                 "CO2_kooldioxide_ul_p_l","O2_zuurstof_ul_p_l",
                 "N2_stikstof_ul_p_l","grensvlakspanning_mN_p_m",
                 "zuurgetal_g_KOH_p_kg","soorslagspanning_kV","tg_delta_x10_4",
                 "specifieke_weerstand_G_Ohm_m","water_gementen_mg_p_kg",
                 "H2T4","C2H6T4","CH4T4","CH4T5","C2H6T5","C2H4T5","CH4T1",
                 "C2H4T1","C2H2T1","H2P1","CH4P1","C2H2P1","C2H4P1",
                 "C2H6P1","T1","T4","T5","P1","P2","Cx","Cy","P90","P9095",
                 "P9599","P99","Markerkleur","TDCG")
  full_data <- set_colum_types(full_data)
  set.seed(42)
  rows <- sample(nrow(full_data))
  full_data <- full_data[rows, ]
  # Selectie =: Variabelen - Y = X
  selectie <- variablen[!variablen %in% Y]
  ## Verwijder alle huidige variablen die niet in de analyse thuishoren. I.e., alleen de lags blijven van X
  keep_from_full<-full_data[ , -which(names(full_data) %in% selectie)]
  
  # Definieer de afhankelijke variable. In andere woorden, de variabele waar de interesse naar uitgaat.
  labels<-as.matrix(keep_from_full[c(Y)])
  
  ## Definieer de onafhankelijke/exogene variabelen voor de analyse.
  vars <-keep_from_full[ , -which(names(keep_from_full) %in% c(Y))]
  
  ## Create train/test data samples
  nn <- as.numeric(NCOL(labels))
  tt <- as.numeric(NROW(labels))
  
  split <- round(as.numeric(tt*.60),0)
  
  # X
  feats <- data.matrix(vars)
  
  ## Full sample
  train_l<-labels[1:split]
  test_l<-labels[(split+1):tt]
  train_f<-feats[1:split,]
  test_f<-feats[(split+1):tt,]
  
  ## Make XGboost data matrix
  train_1 <- xgboost::xgb.DMatrix(data = train_f, label = train_l)
  test_1 <- xgboost::xgb.DMatrix(data = test_f, label = test_l)
  
  # return(train_1)
  training_set <- train_1
  testing_set <- test_1
  
  mData_xgboost <- list(training_set = train_1,testing_set = test_1)
  result <- list(mData = mData_xgboost, UN = full_data$UN, sSplit = split, mTest_data = feats)
  return(result)
}