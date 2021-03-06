voorspelling_2_numeric <- function(vData, Y){
  if (Y == 'H2'){
    sLevels = c(0,3.5,5,7.5,10, 30, 88,210,1070,2140,19300) # 5000 pre-last?
  }else if (Y == 'CH4'){
    sLevels = c(0,2.5,5,7.5,10, 24, 40,59,322,644,52100) # 10100 per-last?
  }else if(Y=='C2H6'){
    sLevels = c(0,0.5,1.5,3, 10, 24,38,123,659,1320,38800) # 6000 pre-last?
  }else if(Y == 'C2H4'){
    sLevels = c(0,0.5,2,3, 10, 24,61,90,720,1440,97000) # 10,000 pre-last?
  }else if (Y == 'C2H2'){
    sLevels = c(0,0.5,2,3, 10, 20,27,90,182,360,6470) # 1500 pre-last
  }
  vForecast <- matrix(NA,nrow=NROW(vData),ncol=1)
  for (i in 1:NROW(vData)){
    sFloor <- floor(vData[i]) + 1
    sCeil <- sFloor + 1
    sDecimal <- vData[i] - floor(vData[i])
    vForecast[i] <- round((sLevels[sFloor] + (sLevels[sCeil] - sLevels[sFloor])*sDecimal),4)
  }
  return(vForecast)
}