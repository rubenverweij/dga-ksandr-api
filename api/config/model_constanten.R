# Dit zijn de verwachte kolommen
verwachte_kolommen <- c(
  "H2",
  "CH4",
  "C2H6",
  "C2H4",
  "C2H2",
  "CO",
  "SerieNr.",
  "Merk",
  "Bouwjaar",
  "OlieSoort",
  "Datum",
  "C4H10n_norm_butaan_ul_p_l",
  "C4H10i_iso_butaan_ul_p_l"
)

# dit zijn volgens de modellen de toegestane merken
merken_toegestaan <-  c("SWT", "AEG", "Ritz", "Smit", "Pauwels", "Lepper", "I.E.O.", 
    "HOLEC", "Trafo-Union", "COQ", "SGB", "Merk onbekend", "ABB", 
    "Crompton Greaves", "Ganz", "Siemens", "ACEC", "Balteau", "BBC", 
    "Garbe-Lahmeyer", "Elin", "Tironi", "ETRA", "Savoisienne", "AREVA", 
    "Tamini", "Helmke", "ASEA", "BEZ", "Ansaldo", "English Electric", 
    "MTC", "Junker", "Babcock", "HTT", "Alstom", "Toshiba", "CEM", 
    "SEA", "Schorch", "Dominit", "EBG", "Fr. Transfo", "Volta-Werke", 
    "Oerlikon", "CGS", "M.W.B.", "Merlin-Gerin", "C.G.E.", "Trench", 
    "Haefely", "Arteche")
  
# dit zijn volgens de modellen de toegestane oliesoorten
oliesoorten_toegestaan <- c("2000", "Diala C", "Diala B", "Diala G", "Nytro 10 GBN", 
    "Diala D", "Diala S2 ZU-I", "Nytro Taurus", "Nytro 10 XN", "Diekan 1500 N", 
    "Mobilect 35 / Castrol B", "Nytro Libra", "Transformer Oil TR 26", 
    "Diala M", "Nytro 3000", "Diala S4 ZX-I", "7131", "Diala S3 ZX-I", 
    "Diala GX", "US 3000 P", "Univolt 62")

# Deze features verwacht het model  
features_model <- c("Bouwjaar", "C4H10n_norm_butaan_ul_p_l", "C4H10i_iso_butaan_ul_p_l", 
              "age_days", "H2_lag", "CH4_lag", "C2H6_lag", "C2H4_lag", "C2H2_lag", 
              "CO_lag", "H2T4_lag", "C2H6T4_lag", "CH4T4_lag", "CH4T5_lag", 
              "C2H6T5_lag", "C2H4T5_lag", "CH4T1_lag", "C2H4T1_lag", "C2H2T1_lag", 
              "H2P1_lag", "CH4P1_lag", "C2H2P1_lag", "C2H4P1_lag", "C2H6P1_lag", 
              "T1_lag", "T4_lag", "T5_lag", "P1_lag", "P2_lag", "Cx_lag", "Cy_lag", 
              "Markerkleur_lag", "TDCG_lag", "TDCGkleur_lag", "H2_lag2", "CH4_lag2", 
              "C2H6_lag2", "C2H4_lag2", "C2H2_lag2", "CO_lag2", "H2T4_lag2", 
              "C2H6T4_lag2", "CH4T4_lag2", "CH4T5_lag2", "C2H6T5_lag2", "C2H4T5_lag2", 
              "CH4T1_lag2", "C2H4T1_lag2", "C2H2T1_lag2", "H2P1_lag2", "CH4P1_lag2", 
              "C2H2P1_lag2", "C2H4P1_lag2", "C2H6P1_lag2", "T1_lag2", "T4_lag2", 
              "T5_lag2", "P1_lag2", "P2_lag2", "Cx_lag2", "Cy_lag2", "Markerkleur_lag2", 
              "TDCG_lag2", "TDCGkleur_lag2", "H2_lag3", "CH4_lag3", "C2H6_lag3", 
              "C2H4_lag3", "C2H2_lag3", "CO_lag3", "H2T4_lag3", "C2H6T4_lag3", 
              "CH4T4_lag3", "CH4T5_lag3", "C2H6T5_lag3", "C2H4T5_lag3", "CH4T1_lag3", 
              "C2H4T1_lag3", "C2H2T1_lag3", "H2P1_lag3", "CH4P1_lag3", "C2H2P1_lag3", 
              "C2H4P1_lag3", "C2H6P1_lag3", "T1_lag3", "T4_lag3", "T5_lag3", 
              "P1_lag3", "P2_lag3", "Cx_lag3", "Cy_lag3", "Markerkleur_lag3", 
              "TDCG_lag3", "TDCGkleur_lag3", "V1_ABB", "V1_ACEC", "V1_AEG", 
              "V1_Alstom", "V1_Ansaldo", "V1_AREVA", "V1_Arteche", "V1_ASEA", 
              "V1_Babcock", "V1_Balteau", "V1_BBC", "V1_BEZ", "V1_C.G.E.", 
              "V1_CEM", "V1_CGS", "V1_COQ", "V1_Crompton Greaves", "V1_Dominit", 
              "V1_EBG", "V1_Elin", "V1_English Electric", "V1_ETRA", "V1_Fr. Transfo", 
              "V1_Ganz", "V1_Garbe-Lahmeyer", "V1_Haefely", "V1_Helmke", "V1_HOLEC", 
              "V1_HTT", "V1_I.E.O.", "V1_Junker", "V1_Lepper", "V1_M.W.B.", 
              "V1_Merk onbekend", "V1_Merlin-Gerin", "V1_MTC", "V1_Oerlikon", 
              "V1_Pauwels", "V1_Ritz", "V1_Savoisienne", "V1_Schorch", "V1_SEA", 
              "V1_SGB", "V1_Siemens", "V1_Smit", "V1_SWT", "V1_Tamini", "V1_Tironi", 
              "V1_Toshiba", "V1_Trafo-Union", "V1_Trench", "V1_Volta-Werke", 
              "V1_2000", "V1_7131", "V1_Diala B", "V1_Diala C", "V1_Diala D", 
              "V1_Diala G", "V1_Diala GX", "V1_Diala M", "V1_Diala S2 ZU-I", 
              "V1_Diala S3 ZX-I", "V1_Diala S4 ZX-I", "V1_Diekan 1500 N", "V1_Mobilect 35 / Castrol B", 
              "V1_Nytro 10 GBN", "V1_Nytro 10 XN", "V1_Nytro 3000", "V1_Nytro Libra", 
              "V1_Nytro Taurus", "V1_Transformer Oil TR 26", "V1_Univolt 62", 
              "V1_US 3000 P")

kwantiel_h2 <- c(-Inf, 3.5, 5, 7.5, 10, 30, 88, 210, 1070, Inf)
kwantiel_CH4 <- c(-Inf, 2.5, 5, 7.5, 10, 30, 24, 59, 322, Inf)
kwantiel_C2H6 <- c(-Inf, 0.5, 1.5, 3, 10, 24, 38, 123, 659, Inf)
kwantiel_C2H4 <- c(-Inf, 0.5, 2, 3, 10, 24, 61, 90, 720, Inf)
kwantiel_C2H2 <- c(-Inf, 0.5, 2, 3, 10, 20, 27, 90, 182, Inf)