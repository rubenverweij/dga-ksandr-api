library(jsonlite)
library(dplyr)

omzetting_json <- function(bestand_pad){
  set.seed(500)
  metingen <- readxl::read_excel(bestand_pad) 
  serienummers <- sample(metingen$SerieNr., 2)
  return(metingen %>% filter(SerieNr. %in% serienummers) %>% toJSON(na = 'string'))
}
  
  
if (!interactive()){
  omzetting_json('../dga-ksandr-api/api/tests/test_dnwg.xlsx')
  
}