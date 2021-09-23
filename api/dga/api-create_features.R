library(plyr)

source("api-select_vars.R")

create_features <- function(data) {
  data <- select_vars(data)
  
  # Deze functie leidt de waardes voor de vorige metingen per transformator af
  d <- data.frame(
    UN = data$SerieNr.,
    H2 = data$H2,
    CH4 = data$CH4,
    C2H6 = data$C2H6,
    C2H4 = data$C2H4,
    C2H2 = data$C2H2,
    CO = data$CO,
    
    # Triangles (9 total)
    H2T4 = data$H2T4,
    C2H6T4 = data$C2H6T4,
    CH4T4 = data$CH4T4,
    
    CH4T5 = data$CH4T5,
    C2H6T5 = data$C2H6T5,
    C2H4T5 = data$C2H4T5,
    
    CH4T1 = data$CH4T1,
    C2H4T1 = data$C2H4T1,
    C2H2T1 = data$C2H2T1,
    
    # Pentagons
    H2P1 = data$H2P1,
    CH4P1 = data$CH4P1,
    C2H2P1 = data$C2H2P1,
    
    C2H4P1 = data$C2H4P1,
    C2H6P1 = data$C2H6P1,
    # Others
    T1 = data$T1,
    T4 = data$T4,
    T5 = data$T5,
    P1 = data$P1,
    P2 = data$P2,
    Cx = data$Cx,
    Cy = data$Cy,
    Markerkleur = as.character(data$Markerkleur),
    TDCG = data$TDCG,
    TDCGkleur = data$TDCGkleur
    
  )
  
  mDf_lag <- plyr::ddply(
    d,
    .(UN),
    transform,
    # This assumes that the data is sorted
    H2_lag = c(NA, H2[-length(H2)]),
    CH4_lag = c(NA, CH4[-length(CH4)]),
    C2H6_lag = c(NA, C2H6[-length(C2H6)]),
    C2H4_lag = c(NA, C2H4[-length(C2H4)]),
    C2H2_lag = c(NA, C2H2[-length(C2H2)]),
    CO_lag = c(NA, CO[-length(CO)]),
    
    H2T4_lag = c(NA, H2T4[-length(H2T4)]),
    C2H6T4_lag = c(NA, C2H6T4[-length(C2H6T4)]),
    CH4T4_lag = c(NA, CH4T4[-length(CH4T4)]),
    
    CH4T5_lag = c(NA, CH4T5[-length(CH4T5)]),
    C2H6T5_lag = c(NA, C2H6T5[-length(C2H6T5)]),
    C2H4T5_lag = c(NA, C2H4T5[-length(C2H4T5)]),
    
    CH4T1_lag = c(NA, CH4T1[-length(CH4T1)]),
    C2H4T1_lag = c(NA, C2H4T1[-length(C2H4T1)]),
    C2H2T1_lag = c(NA, C2H2T1[-length(C2H2T1)]),
    
    # Pentagons
    H2P1_lag = c(NA, H2P1[-length(H2P1)]),
    CH4P1_lag = c(NA, CH4P1[-length(CH4P1)]),
    C2H2P1_lag = c(NA, C2H2P1[-length(C2H2P1)]),
    
    C2H4P1_lag = c(NA, C2H4P1[-length(C2H4P1)]),
    C2H6P1_lag = c(NA, C2H6P1[-length(C2H6P1)]),
    # Others
    T1_lag = c(NA, T1[-length(T1)]),
    T4_lag = c(NA, T4[-length(T4)]),
    T5_lag = c(NA, T5[-length(T5)]),
    P1_lag = c(NA, P1[-length(P1)]),
    P2_lag = c(NA, P2[-length(P2)]),
    Cx_lag = c(NA, Cx[-length(Cx)]),
    Cy_lag = c(NA, Cy[-length(Cy)]),
    Markerkleur_lag = c(NA, Markerkleur[-length(Markerkleur)]),
    TDCG_lag = c(NA, TDCG[-length(TDCG)]),
    TDCGkleur_lag = c(NA, TDCGkleur[-length(TDCGkleur)])
  )
  
  mDf_lag_2 <- plyr::ddply(
    mDf_lag,
    .(UN),
    transform,
    # This assumes that the data is sorted
    H2_lag2 = c(NA, H2_lag[-length(H2)]),
    CH4_lag2 = c(NA, CH4_lag[-length(CH4)]),
    C2H6_lag2 = c(NA, C2H6_lag[-length(C2H6)]),
    C2H4_lag2 = c(NA, C2H4_lag[-length(C2H4)]),
    C2H2_lag2 = c(NA, C2H2_lag[-length(C2H2)]),
    CO_lag2 = c(NA, CO_lag[-length(CO)]),
    
    H2T4_lag2 = c(NA, H2T4_lag[-length(H2T4)]),
    C2H6T4_lag2 = c(NA, C2H6T4_lag[-length(C2H6T4)]),
    CH4T4_lag2 = c(NA, CH4T4_lag[-length(CH4T4)]),
    
    CH4T5_lag2 = c(NA, CH4T5_lag[-length(CH4T5)]),
    C2H6T5_lag2 = c(NA, C2H6T5_lag[-length(C2H6T5)]),
    C2H4T5_lag2 = c(NA, C2H4T5_lag[-length(C2H4T5)]),
    
    CH4T1_lag2 = c(NA, CH4T1_lag[-length(CH4T1)]),
    C2H4T1_lag2 = c(NA, C2H4T1_lag[-length(C2H4T1)]),
    C2H2T1_lag2 = c(NA, C2H2T1_lag[-length(C2H2T1)]),
    
    # Pentagons
    H2P1_lag2 = c(NA, H2P1_lag[-length(H2P1)]),
    CH4P1_lag2 = c(NA, CH4P1_lag[-length(CH4P1)]),
    C2H2P1_lag2 = c(NA, C2H2P1_lag[-length(C2H2P1)]),
    
    C2H4P1_lag2 = c(NA, C2H4P1_lag[-length(C2H4P1)]),
    C2H6P1_lag2 = c(NA, C2H6P1_lag[-length(C2H6P1)]),
    # Others
    T1_lag2 = c(NA, T1_lag[-length(T1)]),
    T4_lag2 = c(NA, T4_lag[-length(T4)]),
    T5_lag2 = c(NA, T5_lag[-length(T5)]),
    P1_lag2 = c(NA, P1_lag[-length(P1)]),
    P2_lag2 = c(NA, P2_lag[-length(P2)]),
    Cx_lag2 = c(NA, Cx_lag[-length(Cx)]),
    Cy_lag2 = c(NA, Cy_lag[-length(Cy)]),
    Markerkleur_lag2 = c(NA, Markerkleur_lag[-length(Markerkleur)]),
    TDCG_lag2 = c(NA, TDCG_lag[-length(TDCG)]),
    TDCGkleur_lag2 = c(NA, TDCGkleur_lag[-length(TDCGkleur)])
  )
  
  mDf_lag_3 <- plyr::ddply(
    mDf_lag_2,
    .(UN),
    transform,
    # This assumes that the data is sorted
    H2_lag3 = c(NA, H2_lag2[-length(H2)]),
    CH4_lag3 = c(NA, CH4_lag2[-length(CH4)]),
    C2H6_lag3 = c(NA, C2H6_lag2[-length(C2H6)]),
    C2H4_lag3 = c(NA, C2H4_lag2[-length(C2H4)]),
    C2H2_lag3 = c(NA, C2H2_lag2[-length(C2H2)]),
    CO_lag3 = c(NA, CO_lag2[-length(CO)]),
    
    H2T4_lag3 = c(NA, H2T4_lag2[-length(H2T4)]),
    C2H6T4_lag3 = c(NA, C2H6T4_lag2[-length(C2H6T4)]),
    CH4T4_lag3 = c(NA, CH4T4_lag2[-length(CH4T4)]),
    
    CH4T5_lag3 = c(NA, CH4T5_lag2[-length(CH4T5)]),
    C2H6T5_lag3 = c(NA, C2H6T5_lag2[-length(C2H6T5)]),
    C2H4T5_lag3 = c(NA, C2H4T5_lag2[-length(C2H4T5)]),
    
    CH4T1_lag3 = c(NA, CH4T1_lag2[-length(CH4T1)]),
    C2H4T1_lag3 = c(NA, C2H4T1_lag2[-length(C2H4T1)]),
    C2H2T1_lag3 = c(NA, C2H2T1_lag2[-length(C2H2T1)]),
    
    # Pentagons
    H2P1_lag3 = c(NA, H2P1_lag2[-length(H2P1)]),
    CH4P1_lag3 = c(NA, CH4P1_lag2[-length(CH4P1)]),
    C2H2P1_lag3 = c(NA, C2H2P1_lag2[-length(C2H2P1)]),
    
    C2H4P1_lag3 = c(NA, C2H4P1_lag2[-length(C2H4P1)]),
    C2H6P1_lag3 = c(NA, C2H6P1_lag2[-length(C2H6P1)]),
    # Others
    T1_lag3 = c(NA, T1_lag2[-length(T1)]),
    T4_lag3 = c(NA, T4_lag2[-length(T4)]),
    T5_lag3 = c(NA, T5_lag2[-length(T5)]),
    P1_lag3 = c(NA, P1_lag2[-length(P1)]),
    P2_lag3 = c(NA, P2_lag2[-length(P2)]),
    Cx_lag3 = c(NA, Cx_lag2[-length(Cx)]),
    Cy_lag3 = c(NA, Cy_lag2[-length(Cy)]),
    Markerkleur_lag3 = c(NA, Markerkleur_lag2[-length(Markerkleur)]),
    TDCG_lag3 = c(NA, TDCG_lag2[-length(TDCG)]),
    TDCGkleur_lag3 = c(NA, TDCGkleur_lag2[-length(TDCGkleur)])
  )
  ## Paste added columns back to original dataframe
  sCol_original <- dim(d)[2]
  sCol_transformed <- dim(mDf_lag_3)[2]
  mDf <-
    cbind(data, mDf_lag_3[, (sCol_original + 1):sCol_transformed])
  
  return(mDf)
}