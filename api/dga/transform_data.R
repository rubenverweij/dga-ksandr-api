source("create_duval_features.R")
source("create_features.R")
source("voorspel_dga.R")
source("../config/file_structure.R")


transform_data <- function(data) {
  
   data <- readxl::read_excel("../tests/single_trafo.xlsx", trim_ws = TRUE, na = c("", "NA"))

  if (!all(required_columns %in% colnames(data)))
    stop("Niet alle kolommen zijn aanwezig in het aangeleverde bestand")
  
  values = create_duval_features(data)
  df_feat = create_features(values)
  return(df_feat)
}