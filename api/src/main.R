#* @apiTitle REST api DGA
#* @apiDescription Deze api is ontwikkeld in opdracht van KSANDR. 
#* Op basis van beschikbare DGA meetwaarden wordt een voorspelling gedaan 
#* van de verwachte ppm waarden van vijf sleutelgassen (C2H2, C2H4, C2H6, CH4, H2)
#* en een risico score. De achterliggende modellen zijn ontwikkeld door studenten in opdracht van KSANDR.
#* 
#* @apiVersion 1.0
#* @apiContact 
#* @apiTag DGA

library(Rcpp)
library(plumber)
library(tidyr)
library(plyr)
library(xgboost)
library(jsonlite)
library(data.table)

source("api-transform_data.R")
source("api-voorspel_dga.R")


# * @filter logger
function(req, res){
  cat(as.character(Sys.time()), "-",
      req$REQUEST_METHOD, req$PATH_INFO, "-",
      req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n", append=TRUE,
      file="/log/api_logs.txt")
  plumber::forward()
}


#* DGA  sleutelgas voorspelling voor transformatoren
#* @param f:file
#* @post /voorspelling_excel
#* @serializer json
function(f) {
  
  tmp <- tempfile("plumb", fileext = paste0("_", basename(names(f))))
  on.exit(unlink(tmp))
  writeBin(f[[1]], tmp)
  
  # Read, transform and predict
  excel_data <-
    readxl::read_excel(
      tmp,
      trim_ws = TRUE,
      na = c("", "NA")
    )
  data_transformed <- transform_data(excel_data)
  prediction <- voorspel_dga(data_transformed)
  prediction$mForecast %>%
    dplyr::distinct(UN, .keep_all = TRUE)

}

#* DGA  sleutelgas voorspelling voor transformatoren
#* @post /voorspelling_json
function(f) {
  
  # Read, transform and predict
  json <- fromJSON(f) %>% as.data.frame
  data_transformed <- transform_data(json)
  prediction <- voorspel_dga(data_transformed)
  prediction$mForecast %>%
    dplyr::distinct(UN, .keep_all = TRUE)
}

#* DGA  sleutelgas voorspelling voor transformatoren
#* @param req  the request object
#* @post /voorspelling_json_file
function(req) {
  # Read, transform and predict
  result <- as.data.frame(lapply(jsonlite::fromJSON(req$postBody), unlist))
  data_transformed <- transform_data(result)
  prediction <- voorspel_dga(data_transformed)
  prediction$mForecast %>%
    dplyr::distinct(UN, .keep_all = TRUE)
}
