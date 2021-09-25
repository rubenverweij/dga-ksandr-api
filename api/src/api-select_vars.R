select_vars <- function(data) {
  
  data$UN <- data$SerieNr.
  
  vDim_string_numeric <-
    dim(data[c(
      'C3H8_propaan_ul_p_l',
      'C3H6_propeen_ul_p_l',
      'C4H10n_norm_butaan_ul_p_l',
      'C4H10i_iso_butaan_ul_p_l',
      'CO2_kooldioxide_ul_p_l',
      'O2_zuurstof_ul_p_l',
      'N2_stikstof_ul_p_l',
      'zuurgetal_g_KOH_p_kg'
    )])
  # Remove string and make numeric
  data[c(
    'C3H8_propaan_ul_p_l',
    'C3H6_propeen_ul_p_l',
    'C4H10n_norm_butaan_ul_p_l',
    'C4H10i_iso_butaan_ul_p_l',
    'CO2_kooldioxide_ul_p_l',
    'O2_zuurstof_ul_p_l',
    'N2_stikstof_ul_p_l',
    'zuurgetal_g_KOH_p_kg'
  )] <-
    matrix(as.numeric(gsub("<", "", as.matrix(data[c(
      'C3H8_propaan_ul_p_l',
      'C3H6_propeen_ul_p_l',
      'C4H10n_norm_butaan_ul_p_l',
      'C4H10i_iso_butaan_ul_p_l',
      'CO2_kooldioxide_ul_p_l',
      'O2_zuurstof_ul_p_l',
      'N2_stikstof_ul_p_l',
      'zuurgetal_g_KOH_p_kg'
    )]))),
    nrow =
      vDim_string_numeric[1], ncol = vDim_string_numeric[2])
  
  # Datum en Bouwjaar
  # Define these character variable columns as factor for one hot encoding
  # 1. We want to express the age, and 2. we want to include the time since last check
  data$age_days <-
    as.numeric(
      as.Date.character(data$Datum, format = '%Y-%m-%d') - as.Date.character(data$Bouwjaar, format = '%Y')
    )
  # data <- data[which(data$apparaat_soort != 'sl'), ]
  
  ## Two columns to drop
  MarkerKleur <- data$Markerkleur
  MarkerKleur_character <- as.character(MarkerKleur)
  data$Markerkleur <- MarkerKleur_character
  data$T1 <- as.numeric(lapply(data$T1, is.na))
  data$T4 <- as.numeric(lapply(data$T4, is.na))
  data$T5 <- as.numeric(lapply(data$T5, is.na))
  data$P1 <- as.numeric(lapply(data$P1, is.na))
  data$P2 <- as.numeric(lapply(data$P2, is.na))
  data$Bouwjaar <- as.numeric(data$Bouwjaar)
  # Bereken de quantielen voor de gaswaardes over de gehele dataset
  data$H2 = as.numeric(cut(data$H2, c(-Inf, 3.5, 5, 7.5, 10, 30, 88, 210, 1070, Inf)))
  data$CH4 = as.numeric(cut(data$CH4, c(-Inf, 2.5, 5, 7.5, 10, 30, 24, 59, 322, Inf), na.rm =
                              T))
  data$C2H6 = as.numeric(cut(data$C2H6, c(-Inf, 0.5, 1.5, 3, 10, 24, 38, 123, 659, Inf), na.rm =
                               T))
  data$C2H4 = as.numeric(cut(data$C2H4, c(-Inf, 0.5, 2, 3, 10, 24, 61, 90, 720, Inf), na.rm =
                               T))
  data$C2H2 = as.numeric(cut(data$C2H2, c(-Inf, 0.5, 2, 3, 10, 20, 27, 90, 182, Inf), na.rm =
                               T))
  return(data)
}