#* @apiTitle REST api DGA
#* @apiDescription Deze api is ontwikkeld in opdracht van KSANDR. 
#* Op basis van beschikbare DGA meetwaarden wordt een voorspelling gedaan 
#* van de verwachte ppm waarden van vijf sleutelgassen (C2H2, C2H4, C2H6, CH4, H2)
#* 
#* De achterliggende modellen zijn ontwikkeld door studenten in opdracht van KSANDR.
#* 
#* @apiVersion 1.0
#* @apiContact ruben.verweij@datapreds.com
#* @apiTag DGA

library(Rcpp)
library(plumber)
library(tidyr)
library(plyr)
library(xgboost)

source("transform_data.R")
source("voorspel_dga.R")


#* DGA  sleutelgas voorspelling voor transformatoren
#* @param f:file
#* @post /voorspelling
#* @serializer json
function(f) {
  
  tmp <- tempfile("plumb", fileext = paste0("_", basename(names(f))))
  on.exit(unlink(tmp))
  writeBin(f[[1]], tmp)
  
  # Read, transform and predict
  excel_data <- readxl::read_excel(tmp, trim_ws = TRUE, na = c("", "NA"))
  data_transformed <- transform_data(excel_data)
  prediction <- voorspel_dga(data_transformed)
  prediction$mForecast %>%
    dplyr::distinct(UN, .keep_all = TRUE)

}