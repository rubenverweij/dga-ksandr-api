source("api-create_duval_features.R")
source("api-create_features.R")
source("api-voorspel_dga.R")
source("../config/model_constanten.R")


transform_data <- function(data) {
  
  if (!all(verwachte_kolommen %in% colnames(data)))
    stop("Niet alle kolommen zijn aanwezig in het aangeleverde bestand")
  
  values = create_duval_features(data)
  df_feat = create_features(values)
  return(df_feat)
}