required_columns <- c(
  "H2",
  "CH4",
  "C2H6",
  "C2H4",
  "C2H2",
  "CO",
  "UN",
  "apparaatsoort",
  "SerieNr.",
  "Merk",
  "Plaats",
  "EigenNr.",
  "Bouwjaar",
  "OlieCode",
  "olieNaam",
  "OlieSoort",
  "Categorie",
  "Datum",
  "Aftappunt",
  "C3H8_propaan_ul_p_l",
  "C3H6_propeen_ul_p_l",
  "C4H10n_norm_butaan_ul_p_l",
  "C4H10i_iso_butaan_ul_p_l",
  "CO2_kooldioxide_ul_p_l",
  "O2_zuurstof_ul_p_l",
  "N2_stikstof_ul_p_l",
  "zuurgetal_g_KOH_p_kg",
  "apparaat_soort"
)

kwantiel_h2 <- c(-Inf,3.5,5,7.5,10, 30, 88,210,1070,Inf)
kwantiel_CH4 <- c(-Inf,2.5,5,7.5,10, 30, 24,59,322,Inf)
kwantiel_C2H6 <- c(-Inf,0.5,1.5,3, 10, 24,38,123,659,Inf)
kwantiel_C2H4 <- c(-Inf,0.5,2,3, 10, 24,61,90,720,Inf)
kwantiel_C2H2 <- c(-Inf,0.5,2,3, 10, 20,27,90,182,Inf)