library(tidyr)

create_duval_features <- function(data) {
  df <- data
  
  ## Deze waardes kunnen universeel (i.e., voor elk bedrijf) worden gebruikt en zijn bepaald via de literatuur van Duval.
  # Let wel, deze variablen zijn eigenlijk zeer belangrijk en dienen tijdens het testen van de voorspellingen eventueel te worden meegenomen
  
  # (1) Met welke grenswaardes moet gerekend worden voor Duval
  GrenswaardeCH4 <- 25
  GrenswaardeC2H4 <- 20
  GrenswaardeC2H2 <- 15
  GrenswaardeH2 <- 150
  GrenswaardeC2H6 <- 10
  
  # (2) Met welke grenswaardes moet gerekend worden voor TDCG
  GrensTDCGNormaal <- 720
  GrensTDCGRiskant <- 1920
  GrensTDCGKritiek <- 4630
  
  # (3) Percentiel waardes 90, 95 en 99
  P90H2 <- 88
  P95H2 <- 210
  P99H2 <- 1070
  
  P90CH4 <- 24
  P95CH4 <- 59
  P99CH4 <- 322
  
  P90C2H2 <- 3
  P95C2H2 <- 27
  P99C2H2 <- 182
  
  P90C2H4 <- 24
  P95C2H4 <- 61
  P99C2H4 <- 720
  
  P90C2H6 <- 38
  P95C2H6 <- 123
  P99C2H6 <- 659
  
  vDim_string_numeric <-
    dim(df[c('H2',
             'CH4',
             'C2H6',
             'C2H4',
             'C2H2',
             'CO')])
  df[c('H2',
       'CH4',
       'C2H6',
       'C2H4',
       'C2H2',
       'CO')] <-
    matrix(as.numeric(gsub("<", "", as.matrix(df[c('H2',
                                                   'CH4',
                                                   'C2H6',
                                                   'C2H4',
                                                   'C2H2',
                                                   'CO')]))), nrow = vDim_string_numeric[1], ncol = vDim_string_numeric[2])
  
  # colnames(df)[KolomnummerH2] <- "H2"
  # colnames(df)[KolomnummerCH4] <- "CH4"
  # colnames(df)[KolomnummerC2H6] <- "C2H6"
  # colnames(df)[KolomnummerC2H4] <- "C2H4"
  # colnames(df)[KolomnummerC2H2] <- "C2H2"
  # colnames(df)[KolomnummerCO] <- "CO"
  # colnames(df)[KolomnummerAftappunt] <- "Aftappunt"
  # colnames(df)[KolomnummerMerk] <- "Merk"
  
  # Remove ± 2000 rows
  df <-
    subset(df,!(H2 == "NA" |
                  CH4 == "NA" |
                  C2H6 == "NA" | C2H4 == "NA" | C2H2 == "NA"))
  # Removes ±1000 rows
  df <- subset(df, Aftappunt == "o")
  
  df[, 'Datum'] <-
    as.Date(df[, 'Datum', drop = TRUE], format = "%Y%m%d")
  df[, 'Datum'] <-
    strftime(df[, 'Datum', drop = TRUE], "%d-%m-%Y")
  df[, 'Datum'] <-
    as.Date(as.character(df[, 'Datum', drop = TRUE]), "%d-%m-%Y")
  
  # colnames(df)[KolomnummerDatum] <- "Datum"
  # colnames(df)[KolomnummerSerieNummer] <- "SerieNr."
  # colnames(df)[KolomnummerEigenNummer] <- "EigenNr."
  # colnames(df)[KolomnummerPlaats] <- "Plaats"
  # colnames(df)[KolomnummerBouwjaar] <- "Bouwjaar"
  # colnames(df)[1] <- "UN"
  # colnames(df)[KolomnummerOlieCode] <- "OlieCode"
  # colnames(df)[KolomnummerOlieNaam] <- "olieNaam"
  # colnames(df)[KolomnummerOlieSoort] <- "OlieSoort"
  # colnames(df)[KolomnummerCategorie] <- "Categorie"
  
  df <- subset(df, Datum >= as.Date("2000-01-01"))
  df[, 'Datum'] <-
    strftime(df[, 'Datum', drop = TRUE], "%d-%m-%Y")
  
  df <-
    within(df, Bouwjaar[!is.na(Bouwjaar) &
                          substr(Bouwjaar, 1, 2) < 30] <-
             paste("20", substr(Bouwjaar[!is.na(Bouwjaar) &
                                           substr(Bouwjaar, 1, 2) < 30] , 1, 2), sep = ""))
  df <-
    within(df, Bouwjaar[!is.na(Bouwjaar) &
                          substr(Bouwjaar, 1, 2) >= 30] <-
             paste("19", substr(Bouwjaar[!is.na(Bouwjaar) &
                                           substr(Bouwjaar, 1, 2) >= 30] , 1, 2), sep = ""))
  
  Transformatoren <- unique(df[1:14])
  Transformatoren <-
    Transformatoren[order(Transformatoren[, 'Plaats', drop = TRUE],
                          Transformatoren[, 'SerieNr.', drop = TRUE],
                          Transformatoren[, 'EigenNr.', drop = TRUE]),]
  Transformatoren[1] <- rownames(Transformatoren)
  
  df <-
    df[order(df[, 'Plaats', drop = TRUE], df[, 'SerieNr.', drop = TRUE],
             df[, 'EigenNr.', drop = TRUE], as.Date(df[, 'Datum', drop = TRUE], format =
                                                      "%d-%m-%Y")),]
  
  # df['UN'] <-
  #   left_join(df, Transformatoren, by = c("SerieNr.", "EigenNr.", "Plaats"))["UN.y"]
  Transformatoren[, 'EigenNr.'] <-
    replace_na(Transformatoren[, 'EigenNr.', drop = TRUE], "Onbekend")
  Transformatoren[, 'Plaats'] <-
    replace_na(Transformatoren[, 'Plaats', drop = TRUE], "Onbekend")
  
  #Uitvoeren Duval Triangle --------------------------------------------------------------------
  df$H2T4 = df$H2 / (df$H2 + df$CH4 + df$C2H6) * 100
  df$C2H6T4 = df$C2H6 / (df$H2 + df$CH4 + df$C2H6) * 100
  df$CH4T4 = df$CH4 / (df$H2 + df$CH4 + df$C2H6) * 100
  df$CH4T5 = df$CH4 / (df$C2H4 + df$CH4 + df$C2H6) * 100
  df$C2H6T5 = df$C2H6 / (df$C2H4 + df$CH4 + df$C2H6) * 100
  df$C2H4T5 = df$C2H4 / (df$C2H4 + df$CH4 + df$C2H6) * 100
  df$CH4T1 = df$CH4 / (df$C2H2 + df$CH4 + df$C2H4) * 100
  df$C2H4T1 = df$C2H4 / (df$C2H2 + df$CH4 + df$C2H4) * 100
  df$C2H2T1 = df$C2H2 / (df$C2H2 + df$CH4 + df$C2H4) * 100
  
  df$H2P1 = df$H2 / (df$H2 + df$CH4 + df$C2H2 + df$C2H4 + df$C2H6) * 100
  df$CH4P1 = df$CH4 / (df$H2 + df$CH4 + df$C2H2 + df$C2H4 + df$C2H6) * 100
  df$C2H2P1 = df$C2H2 / (df$H2 + df$CH4 + df$C2H2 + df$C2H4 + df$C2H6) * 100
  df$C2H4P1 = df$C2H4 / (df$H2 + df$CH4 + df$C2H2 + df$C2H4 + df$C2H6) * 100
  df$C2H6P1 = df$C2H6 / (df$H2 + df$CH4 + df$C2H2 + df$C2H4 + df$C2H6) * 100
  
  df$Triangle1 <- "DT"
  df <- within(df, Triangle1[C2H2T1 >= 13 & C2H4T1 <= 23] <- "D1")
  df <- within(df, Triangle1[C2H2T1 <= 4 & C2H4T1 <= 20] <- "T1")
  df <- within(df, Triangle1[C2H2T1 <= 4 & C2H4T1 >= 20] <- "T2")
  df <- within(df, Triangle1[C2H2T1 <= 15 & C2H4T1 >= 50] <- "T3")
  df <-
    within(df, Triangle1[(C2H2T1 >= 13 &
                            C2H4T1 >= 23 &
                            C2H4T1 <= 40) |
                           (C2H2T1 >= 29 & C2H4T1 >= 40)] <- "D2")
  df <- within(df, Triangle1[CH4T1 >= 98] <- "PD")
  df <-
    within(df, Triangle1[C2H2 < GrenswaardeC2H2 &
                           CH4 < GrenswaardeCH4 &
                           C2H4 < GrenswaardeC2H4] <- NA)
  
  df$Triangle4 <- NA
  df <-
    within(df, Triangle4[(Triangle1 == "PD" |
                            Triangle1 == "T1"  |
                            Triangle1 == "T2")] <- "S")
  df <-
    within(df, Triangle4[(Triangle1 == "PD" |
                            Triangle1 == "T1"  |
                            Triangle1 == "T2") &
                           C2H6T4 >= 46] <- "ND")
  df <-
    within(df, Triangle4[(Triangle1 == "PD" |
                            Triangle1 == "T1"  |
                            Triangle1 == "T2") & H2T4 <= 9] <- "O")
  df <-
    within(df, Triangle4[(Triangle1 == "PD" |
                            Triangle1 == "T1"  |
                            Triangle1 == "T2") &
                           ((CH4T4 >= 36 &
                               C2H6T4 <= 24) |
                              (C2H6T4 <= 30 & H2T4 <= 15))] <- "C")
  df <-
    within(df, Triangle4[(Triangle1 == "PD" |
                            Triangle1 == "T1"  |
                            Triangle1 == "T2") &
                           C2H6T4 <= 1 &
                           CH4T4 >= 2 & CH4T4 <= 15] <- "PD")
  
  df$Triangle5 <- NA
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3")] <- "T3")
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3") &
                           ((C2H6T5 >= 12 &
                               C2H6T5 <= 30 &
                               C2H4T5 <= 49) |
                              (C2H6T5 >= 14 &
                                 C2H6T5 <= 30 &
                                 C2H4T5 <= 70))] <- "C")
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3") &
                           C2H6T5 <= 12 & C2H4T5 <= 35] <- "T2")
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3") &
                           C2H6T5 >= 30 & C2H4T5 <= 35] <- "ND")
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3") &
                           C2H4T5 <= 10] <- "O")
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3") &
                           C2H6T5 >= 15 &
                           C2H6T5 <= 54 & C2H4T5 <= 10] <- "S")
  df <-
    within(df, Triangle5[(Triangle1 == "PD" |
                            Triangle1 == "T2"  |
                            Triangle1 == "T3") &
                           C2H6T5 >= 2 &
                           C2H6T5 <= 15 & C2H4T5 <= 1] <- "PD")
  
  #Uitvoeren Duval Pentagon --------------------------------------------------------------------
  df$Pentagon1 <- 1
  df$Pentagon2 <- NA
  
  df <-
    within(df, Pentagon1[C2H2 < GrenswaardeC2H2 &
                           CH4 < GrenswaardeCH4 &
                           C2H4 < GrenswaardeC2H4 &
                           C2H6 < GrenswaardeC2H6 &
                           H2 < GrenswaardeH2] <- NA)
  df$Cx <- NA
  df <-
    within(df, Cx[!is.na(Pentagon1)] <-
             (1 / (3 * (((0 * (
               C2H6P1[!is.na(Pentagon1)] * sin(17.5255683737229 * pi / 180)
             )) -
               ((
                 C2H6P1[!is.na(Pentagon1)] * -cos(17.5255683737229 * pi / 180)
               ) *
                 H2P1[!is.na(Pentagon1)])) + (((
                   C2H6P1[!is.na(Pentagon1)] *
                     -cos(17.5255683737229 * pi / 180)
                 ) * (
                   CH4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 )) - ((
                   CH4P1[!is.na(Pentagon1)] *
                     -sin(36.098283967108 * pi / 180)
                 ) * (
                   C2H6P1[!is.na(Pentagon1)] *
                     sin(17.5255683737229 * pi / 180)
                 ))) + (((
                   CH4P1[!is.na(Pentagon1)] *
                     -sin(36.098283967108 * pi / 180)
                 ) * (
                   C2H4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 )) - ((
                   C2H4P1[!is.na(Pentagon1)] *
                     sin(36.098283967108 * pi / 180)
                 ) * (
                   CH4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 ))) + (((
                   C2H4P1[!is.na(Pentagon1)] *
                     sin(36.098283967108 * pi / 180)
                 ) * (
                   C2H2P1[!is.na(Pentagon1)] *
                     sin(17.5255683737229 * pi / 180)
                 )) - ((
                   C2H2P1[!is.na(Pentagon1)] *
                     cos(17.5255683737229 * pi / 180)
                 ) * (
                   C2H4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 )))
             ))) *
             (((
               0 + (C2H6P1[!is.na(Pentagon1)] * -cos(17.5255683737229 * pi / 180))
             ) *
               ((
                 0 * (C2H6P1[!is.na(Pentagon1)] * sin(17.5255683737229 * pi / 180))
               ) -
                 ((C2H6P1[!is.na(Pentagon1)] * -cos(17.5255683737229 * pi / 180)) *
                    H2P1[!is.na(Pentagon1)]
                 ))) + (((C2H6P1[!is.na(Pentagon1)] *
                            -cos(17.5255683737229 * pi / 180)) + (CH4P1[!is.na(Pentagon1)] *
                                                                    -sin(36.098283967108 * pi / 180))
                 ) * (((C2H6P1[!is.na(Pentagon1)] *
                          -cos(17.5255683737229 * pi / 180)) * (CH4P1[!is.na(Pentagon1)] *
                                                                  -cos(36.098283967108 * pi / 180))
                 ) - ((CH4P1[!is.na(Pentagon1)] *
                         -sin(36.098283967108 * pi / 180)) * (C2H6P1[!is.na(Pentagon1)] *
                                                                sin(17.5255683737229 * pi / 180))
                 ))) + (((CH4P1[!is.na(Pentagon1)] *
                            -sin(36.098283967108 * pi / 180)) + (C2H4P1[!is.na(Pentagon1)] *
                                                                   sin(36.098283967108 * pi / 180))
                 ) * (((CH4P1[!is.na(Pentagon1)] *
                          -sin(36.098283967108 * pi / 180)) * (C2H4P1[!is.na(Pentagon1)] *
                                                                 -cos(36.098283967108 * pi / 180))
                 ) - ((C2H4P1[!is.na(Pentagon1)] *
                         sin(36.098283967108 * pi / 180)) * (CH4P1[!is.na(Pentagon1)] *
                                                               -cos(36.098283967108 * pi / 180))
                 ))) + (((C2H4P1[!is.na(Pentagon1)] *
                            sin(36.098283967108 * pi / 180)) + (C2H2P1[!is.na(Pentagon1)] *
                                                                  cos(17.5255683737229 * pi / 180))
                 ) * (((C2H4P1[!is.na(Pentagon1)] *
                          sin(36.098283967108 * pi / 180)) * (C2H2P1[!is.na(Pentagon1)] *
                                                                sin(17.5255683737229 * pi / 180))
                 ) - ((C2H2P1[!is.na(Pentagon1)] *
                         cos(17.5255683737229 * pi / 180)) * (C2H4P1[!is.na(Pentagon1)] *
                                                                -cos(36.098283967108 * pi / 180))
                 )))))
  df$Cy <- NA
  df <-
    within(df, Cy[!is.na(Pentagon1)] <-
             (1 / (3 * (((0 * (
               C2H6P1[!is.na(Pentagon1)] * sin(17.5255683737229 * pi / 180)
             )) -
               ((
                 C2H6P1[!is.na(Pentagon1)] * -cos(17.5255683737229 * pi / 180)
               ) *
                 H2P1[!is.na(Pentagon1)])) + (((
                   C2H6P1[!is.na(Pentagon1)] *
                     -cos(17.5255683737229 * pi / 180)
                 ) * (
                   CH4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 )) - ((
                   CH4P1[!is.na(Pentagon1)] *
                     -sin(36.098283967108 * pi / 180)
                 ) * (
                   C2H6P1[!is.na(Pentagon1)] *
                     sin(17.5255683737229 * pi / 180)
                 ))) + (((
                   CH4P1[!is.na(Pentagon1)] *
                     -sin(36.098283967108 * pi / 180)
                 ) * (
                   C2H4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 )) - ((
                   C2H4P1[!is.na(Pentagon1)] *
                     sin(36.098283967108 * pi / 180)
                 ) * (
                   CH4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 ))) + (((
                   C2H4P1[!is.na(Pentagon1)] *
                     sin(36.098283967108 * pi / 180)
                 ) * (
                   C2H2P1[!is.na(Pentagon1)] *
                     sin(17.5255683737229 * pi / 180)
                 )) - ((
                   C2H2P1[!is.na(Pentagon1)] *
                     cos(17.5255683737229 * pi / 180)
                 ) * (
                   C2H4P1[!is.na(Pentagon1)] *
                     -cos(36.098283967108 * pi / 180)
                 )))
             ))) * (((
               H2P1[!is.na(Pentagon1)] +
                 (C2H6P1[!is.na(Pentagon1)] * sin(17.5255683737229 * pi / 180))
             ) *
               ((
                 0 * (C2H6P1[!is.na(Pentagon1)] * sin(17.5255683737229 * pi / 180))
               ) -
                 ((C2H6P1[!is.na(Pentagon1)] * -cos(17.5255683737229 * pi / 180)) *
                    H2P1[!is.na(Pentagon1)]
                 ))) + (((C2H6P1[!is.na(Pentagon1)] *
                            sin(17.5255683737229 * pi / 180)) + (CH4P1[!is.na(Pentagon1)] *
                                                                   -cos(36.098283967108 * pi / 180))
                 ) * (((C2H6P1[!is.na(Pentagon1)] *
                          -cos(17.5255683737229 * pi / 180)) * (CH4P1[!is.na(Pentagon1)] *
                                                                  -cos(36.098283967108 * pi / 180))
                 ) - ((CH4P1[!is.na(Pentagon1)] *
                         -sin(36.098283967108 * pi / 180)) * (C2H6P1[!is.na(Pentagon1)] *
                                                                sin(17.5255683737229 * pi / 180))
                 ))) + (((CH4P1[!is.na(Pentagon1)] *
                            -cos(36.098283967108 * pi / 180)) + (C2H4P1[!is.na(Pentagon1)] *
                                                                   -cos(36.098283967108 * pi / 180))
                 ) * (((CH4P1[!is.na(Pentagon1)] *
                          -sin(36.098283967108 * pi / 180)) * (C2H4P1[!is.na(Pentagon1)] *
                                                                 -cos(36.098283967108 * pi / 180))
                 ) - ((C2H4P1[!is.na(Pentagon1)] *
                         sin(36.098283967108 * pi / 180)) * (CH4P1[!is.na(Pentagon1)] *
                                                               -cos(36.098283967108 * pi / 180))
                 ))) + (((C2H4P1[!is.na(Pentagon1)] *
                            -cos(36.098283967108 * pi / 180)) + (C2H2P1[!is.na(Pentagon1)] *
                                                                   sin(17.5255683737229 * pi / 180))
                 ) * (((C2H4P1[!is.na(Pentagon1)] *
                          sin(36.098283967108 * pi / 180)) * (C2H2P1[!is.na(Pentagon1)] *
                                                                sin(17.5255683737229 * pi / 180))
                 ) - ((C2H2P1[!is.na(Pentagon1)] *
                         cos(17.5255683737229 * pi / 180)) * (C2H4P1[!is.na(Pentagon1)] *
                                                                -cos(36.098283967108 * pi / 180))
                 )))))
  
  df <- within(df, Pentagon1[!is.na(Pentagon1)] <- "T1")
  df <- within(df, Pentagon1[!is.na(Pentagon1) & Cx >= 0] <- "D1")
  df <-
    within(df, Pentagon1[!is.na(Pentagon1) &
                           Cy <= ((Cx * (56 / 33)) + (68 / 11)) &
                           Cy <= ((-Cx * 4) - 28)] <- "T2")
  df <-
    within(df, Pentagon1[!is.na(Pentagon1) &
                           Cy <= ((Cx * 0.4) - 1.6) &
                           Cy <= ((-Cx * (28 / 25)) - (78 / 25)) &
                           Cy >=
                           ((-Cx * 4) - 28)] <- "T3")
  df <-
    within(df, Pentagon1[!is.na(Pentagon1) &
                           ((Cy <= 1.5 & Cy <= ((-Cx * (
                             22 / 28
                           )) + (134 / 7)) & Cy <=
                             ((Cx * 3.5) + 1.5) &
                             Cy >= ((-Cx * (
                               28 / 25
                             )) - (78 / 25))) |
                             (Cy >= 1.5 &
                                Cy <= ((Cx * (
                                  29 / 8
                                )) + 1.5) & Cy <=
                                ((-Cx * (
                                  22 / 28
                                )) + (134 / 7))))] <- "D2")
  df <-
    within(df, Pentagon1[!is.na(Pentagon1) &
                           Cx < 0 &
                           Cy > ((-Cx * (3 / 70)) + 1.5)] <- "S")
  df <-
    within(df, Pentagon1[!is.na(Pentagon1) &
                           Cx <= 0 &
                           Cx >= -1 &
                           Cy >= 24.5 & Cy <= 33] <- "PD")
  
  df <-
    within(df, Pentagon2[(Pentagon1 == "T1" |
                            Pentagon1 == "T2" |
                            Pentagon1 == "T3")] <- "O")
  df <-
    within(df, Pentagon2[(Pentagon1 == "T1" |
                            Pentagon1 == "T2" |
                            Pentagon1 == "T3") &
                           Cy <= ((Cx * (2 / 3)) - (2 / 3)) &
                           Cy <= ((-Cx * (29 / 6)) - (167 / 12)) &
                           Cy <= ((Cx * (48 / 21)) + (120 / 7))] <-
             "C")
  df <-
    within(df, Pentagon2[(Pentagon1 == "T1" |
                            Pentagon1 == "T2" |
                            Pentagon1 == "T3") &
                           Cy <= ((-Cx * (28 / 25)) - (78 / 25)) &
                           Cy <= ((Cx * 0.4) - 1.6) &
                           Cy >= ((-Cx * (29 / 6)) - (167 / 12))] <-
             "T3-H")
  
  #Percentiel hoeveelheid per meting per gassoort vaststellen --------------------------------------------------------------------
  df$P90 <- NA
  df$P9095 <- NA
  df$P9599 <- NA
  df$P99 <- NA
  
  df <- within(df, P90[H2 <= P90H2] <- "H2")
  df <-
    within(df, P90[!is.na(P90) &
                     CH4 <= P90CH4] <-
             paste(P90[!is.na(P90) & CH4 <= P90CH4], ", CH4"))
  df <- within(df, P90[is.na(P90) & CH4 <= P90CH4] <- "CH4")
  df <-
    within(df, P90[!is.na(P90) &
                     C2H2 <= P90C2H2] <-
             paste(P90[!is.na(P90) & C2H2 <= P90C2H2], ", C2H2"))
  df <- within(df, P90[is.na(P90) & C2H2 <= P90C2H2] <- "C2H2")
  df <-
    within(df, P90[!is.na(P90) &
                     C2H4 <= P90C2H4] <-
             paste(P90[!is.na(P90) & C2H4 <= P90C2H4], ", C2H4"))
  df <- within(df, P90[is.na(P90) & C2H4 <= P90C2H4] <- "C2H4")
  df <-
    within(df, P90[!is.na(P90) &
                     C2H6 <= P90C2H6] <-
             paste(P90[!is.na(P90) & C2H6 <= P90C2H6], ", C2H6"))
  df <- within(df, P90[is.na(P90) & C2H6 <= P90C2H6] <- "C2H6")
  
  df <- within(df, P9095[H2 > P90H2 & H2 <= P95H2] <- "H2")
  df <-
    within(df, P9095[!is.na(P9095) &
                       CH4 > P90CH4 &
                       CH4 <= P95CH4] <-
             paste(P9095[!is.na(P9095) & CH4 > P90CH4 &
                           CH4 <= P95CH4], ", CH4"))
  df <-
    within(df, P9095[is.na(P9095) &
                       CH4 > P90CH4 & CH4 <= P95CH4] <- "CH4")
  df <-
    within(df, P9095[!is.na(P9095) &
                       C2H2 > P90C2H2 &
                       C2H2 <= P95C2H2] <-
             paste(P9095[!is.na(P9095) & C2H2 > P90C2H2 &
                           C2H2 <= P95C2H2], ", C2H2"))
  df <-
    within(df, P9095[is.na(P9095) &
                       C2H2 > P90C2H2 & C2H2 <= P95C2H2] <- "C2H2")
  df <-
    within(df, P9095[!is.na(P9095) &
                       C2H4 > P90C2H4 &
                       C2H4 <= P95C2H4] <-
             paste(P9095[!is.na(P9095) & C2H4 > P90C2H4 &
                           C2H4 <= P95C2H4], ", C2H4"))
  df <-
    within(df, P9095[is.na(P9095) &
                       C2H4 > P90C2H4 & C2H4 <= P95C2H4] <- "C2H4")
  df <-
    within(df, P9095[!is.na(P9095) &
                       C2H6 > P90C2H6 &
                       C2H6 <= P95C2H6] <-
             paste(P9095[!is.na(P9095) & C2H6 > P90C2H6 &
                           C2H6 <= P95C2H6], ", C2H6"))
  df <-
    within(df, P9095[is.na(P9095) &
                       C2H6 > P90C2H6 & C2H6 <= P95C2H6] <- "C2H6")
  
  df <- within(df, P9599[H2 > P95H2 & H2 <= P99H2] <- "H2")
  df <-
    within(df, P9599[!is.na(P9599) &
                       CH4 > P95CH4 &
                       CH4 <= P99CH4] <-
             paste(P9599[!is.na(P9599) & CH4 > P95CH4 & CH4 <=
                           P99CH4], ", CH4"))
  df <-
    within(df, P9599[is.na(P9599) &
                       CH4 > P95CH4 & CH4 <= P99CH4] <- "CH4")
  df <-
    within(df, P9599[!is.na(P9599) &
                       C2H2 > P95C2H2 &
                       C2H2 <= P99C2H2] <-
             paste(P9599[!is.na(P9599) & C2H2 > P95C2H2 &
                           C2H2 <= P99C2H2], ", C2H2"))
  df <-
    within(df, P9599[is.na(P9599) &
                       C2H2 > P95C2H2 & C2H2 <= P99C2H2] <- "C2H2")
  df <-
    within(df, P9599[!is.na(P9599) &
                       C2H4 > P95C2H4 &
                       C2H4 <= P99C2H4] <-
             paste(P9599[!is.na(P9599) & C2H4 > P95C2H4 &
                           C2H4 <= P99C2H4], ", C2H4"))
  df <-
    within(df, P9599[is.na(P9599) &
                       C2H4 > P95C2H4 & C2H4 <= P99C2H4] <- "C2H4")
  df <-
    within(df, P9599[!is.na(P9599) &
                       C2H6 > P95C2H6 &
                       C2H6 <= P99C2H6] <-
             paste(P9599[!is.na(P9599) & C2H6 > P95C2H6 &
                           C2H6 <= P99C2H6], ", C2H6"))
  df <-
    within(df, P9599[is.na(P9599) &
                       C2H6 > P95C2H6 & C2H6 <= P99C2H6] <- "C2H6")
  
  df <- within(df, P99[H2 > P99H2] <- "H2")
  df <-
    within(df, P99[!is.na(P99) &
                     CH4 > P99CH4] <-
             paste(P99[!is.na(P99) & CH4 > P99CH4], ", CH4"))
  df <- within(df, P99[is.na(P99) & CH4 > P99CH4] <- "CH4")
  df <-
    within(df, P99[!is.na(P99) &
                     C2H2 > P99C2H2] <-
             paste(P99[!is.na(P99) & C2H2 > P99C2H2], ", C2H2"))
  df <- within(df, P99[is.na(P99) & C2H2 > P99C2H2] <- "C2H2")
  df <-
    within(df, P99[!is.na(P99) &
                     C2H4 > P99C2H4] <-
             paste(P99[!is.na(P99) & C2H4 > P99C2H4], ", C2H4"))
  df <- within(df, P99[is.na(P99) & C2H4 > P99C2H4] <- "C2H4")
  df <-
    within(df, P99[!is.na(P99) &
                     C2H6 > P99C2H6] <-
             paste(P99[!is.na(P99) & C2H6 > P99C2H6], ", C2H6"))
  df <- within(df, P99[is.na(P99) & C2H6 > P99C2H6] <- "C2H6")
  
  #Kleur voor de marker vaststellen --------------------------------------------------------------------
  df$Markerkleur <- NA
  
  df <- within(df, Markerkleur[] <- "green")
  df <- within(df, Markerkleur[!is.na(P9095)] <- "orange")
  df <- within(df, Markerkleur[!is.na(P9599)] <- "red")
  df <- within(df, Markerkleur[!is.na(P99)] <- "purple")
  
  df$Markerkleur <- as.factor(df$Markerkleur)
  # factor(df$Markerkleur, labels = c("green", "orange", "red", "purple"))
  
  colnames(df)[which(names(df) == "Triangle1")] <- "T1"
  colnames(df)[which(names(df) == "Triangle4")] <- "T4"
  colnames(df)[which(names(df) == "Triangle5")] <- "T5"
  colnames(df)[which(names(df) == "Pentagon1")] <- "P1"
  colnames(df)[which(names(df) == "Pentagon2")] <- "P2"
  
  #TDCG en bepalen meet frequentie extra metingen --------------------------------------------------------------------
  df$TDCG <- df$H2 + df$CH4 + df$C2H2 + df$C2H4 + df$C2H6 + df$CO
  
  df$TDCGkleur <- NA
  
  df <- within(df, TDCGkleur[] <- "0")
  df <- within(df, TDCGkleur[TDCG >= GrensTDCGNormaal] <- "1")
  df <- within(df, TDCGkleur[TDCG >= GrensTDCGRiskant] <- "2")
  df <- within(df, TDCGkleur[TDCG >= GrensTDCGKritiek] <- "3")
  Transformatoren <<- Transformatoren
  return(df)
}