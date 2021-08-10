#
# This is a Plumber API. You can run the API by clicking
# the 'Run API' button above.
#
# Find out more about building APIs with Plumber here:
#
#    https://www.rplumber.io/
#

library(plumber)
library(tidyr)
library(plyr)
library(xgboost)

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
    subset(df,
           !(H2 == "NA" |
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
                          Transformatoren[, 'EigenNr.', drop = TRUE]), ]
  Transformatoren[1] <- rownames(Transformatoren)
  
  df <-
    df[order(df[, 'Plaats', drop = TRUE], df[, 'SerieNr.', drop = TRUE],
             df[, 'EigenNr.', drop = TRUE], as.Date(df[, 'Datum', drop = TRUE], format =
                                                      "%d-%m-%Y")), ]
  
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

select_vars <- function(data) {
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
      as.Date.character(data$Datum, format = '%d-%m-%Y') - as.Date.character(data$Bouwjaar, format = '%Y')
    )
  data <- data[which(data$apparaat_soort != 'sl'), ]
  
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

create_features <- function(data) {
  data <- select_vars(data)
  
  # Deze functie leidt de waardes voor de vorige metingen per transformator af
  d <- data.frame(
    UN = data$UN,
    H2 = data$H2,
    CH4 = data$CH4,
    C2H6 = data$C2H6,
    C2H4 = data$C2H4,
    C2H2 = data$C2H2,
    CO = data$CO,
    
    # Triangles (9 total)
    H2T4 = data$H2T4,
    C2H6T4 = data$C2H6T4,
    CH4T4 = data$CH4T4,
    
    CH4T5 = data$CH4T5,
    C2H6T5 = data$C2H6T5,
    C2H4T5 = data$C2H4T5,
    
    CH4T1 = data$CH4T1,
    C2H4T1 = data$C2H4T1,
    C2H2T1 = data$C2H2T1,
    
    # Pentagons
    H2P1 = data$H2P1,
    CH4P1 = data$CH4P1,
    C2H2P1 = data$C2H2P1,
    
    C2H4P1 = data$C2H4P1,
    C2H6P1 = data$C2H6P1,
    # Others
    T1 = data$T1,
    T4 = data$T4,
    T5 = data$T5,
    P1 = data$P1,
    P2 = data$P2,
    Cx = data$Cx,
    Cy = data$Cy,
    Markerkleur = as.character(data$Markerkleur),
    TDCG = data$TDCG,
    TDCGkleur = data$TDCGkleur
    
  )
  
  mDf_lag <- plyr::ddply(
    d,
    .(UN),
    transform,
    # This assumes that the data is sorted
    H2_lag = c(NA, H2[-length(H2)]),
    CH4_lag = c(NA, CH4[-length(CH4)]),
    C2H6_lag = c(NA, C2H6[-length(C2H6)]),
    C2H4_lag = c(NA, C2H4[-length(C2H4)]),
    C2H2_lag = c(NA, C2H2[-length(C2H2)]),
    CO_lag = c(NA, CO[-length(CO)]),
    
    H2T4_lag = c(NA, H2T4[-length(H2T4)]),
    C2H6T4_lag = c(NA, C2H6T4[-length(C2H6T4)]),
    CH4T4_lag = c(NA, CH4T4[-length(CH4T4)]),
    
    CH4T5_lag = c(NA, CH4T5[-length(CH4T5)]),
    C2H6T5_lag = c(NA, C2H6T5[-length(C2H6T5)]),
    C2H4T5_lag = c(NA, C2H4T5[-length(C2H4T5)]),
    
    CH4T1_lag = c(NA, CH4T1[-length(CH4T1)]),
    C2H4T1_lag = c(NA, C2H4T1[-length(C2H4T1)]),
    C2H2T1_lag = c(NA, C2H2T1[-length(C2H2T1)]),
    
    # Pentagons
    H2P1_lag = c(NA, H2P1[-length(H2P1)]),
    CH4P1_lag = c(NA, CH4P1[-length(CH4P1)]),
    C2H2P1_lag = c(NA, C2H2P1[-length(C2H2P1)]),
    
    C2H4P1_lag = c(NA, C2H4P1[-length(C2H4P1)]),
    C2H6P1_lag = c(NA, C2H6P1[-length(C2H6P1)]),
    # Others
    T1_lag = c(NA, T1[-length(T1)]),
    T4_lag = c(NA, T4[-length(T4)]),
    T5_lag = c(NA, T5[-length(T5)]),
    P1_lag = c(NA, P1[-length(P1)]),
    P2_lag = c(NA, P2[-length(P2)]),
    Cx_lag = c(NA, Cx[-length(Cx)]),
    Cy_lag = c(NA, Cy[-length(Cy)]),
    Markerkleur_lag = c(NA, Markerkleur[-length(Markerkleur)]),
    TDCG_lag = c(NA, TDCG[-length(TDCG)]),
    TDCGkleur_lag = c(NA, TDCGkleur[-length(TDCGkleur)])
  )
  
  mDf_lag_2 <- plyr::ddply(
    mDf_lag,
    .(UN),
    transform,
    # This assumes that the data is sorted
    H2_lag2 = c(NA, H2_lag[-length(H2)]),
    CH4_lag2 = c(NA, CH4_lag[-length(CH4)]),
    C2H6_lag2 = c(NA, C2H6_lag[-length(C2H6)]),
    C2H4_lag2 = c(NA, C2H4_lag[-length(C2H4)]),
    C2H2_lag2 = c(NA, C2H2_lag[-length(C2H2)]),
    CO_lag2 = c(NA, CO_lag[-length(CO)]),
    
    H2T4_lag2 = c(NA, H2T4_lag[-length(H2T4)]),
    C2H6T4_lag2 = c(NA, C2H6T4_lag[-length(C2H6T4)]),
    CH4T4_lag2 = c(NA, CH4T4_lag[-length(CH4T4)]),
    
    CH4T5_lag2 = c(NA, CH4T5_lag[-length(CH4T5)]),
    C2H6T5_lag2 = c(NA, C2H6T5_lag[-length(C2H6T5)]),
    C2H4T5_lag2 = c(NA, C2H4T5_lag[-length(C2H4T5)]),
    
    CH4T1_lag2 = c(NA, CH4T1_lag[-length(CH4T1)]),
    C2H4T1_lag2 = c(NA, C2H4T1_lag[-length(C2H4T1)]),
    C2H2T1_lag2 = c(NA, C2H2T1_lag[-length(C2H2T1)]),
    
    # Pentagons
    H2P1_lag2 = c(NA, H2P1_lag[-length(H2P1)]),
    CH4P1_lag2 = c(NA, CH4P1_lag[-length(CH4P1)]),
    C2H2P1_lag2 = c(NA, C2H2P1_lag[-length(C2H2P1)]),
    
    C2H4P1_lag2 = c(NA, C2H4P1_lag[-length(C2H4P1)]),
    C2H6P1_lag2 = c(NA, C2H6P1_lag[-length(C2H6P1)]),
    # Others
    T1_lag2 = c(NA, T1_lag[-length(T1)]),
    T4_lag2 = c(NA, T4_lag[-length(T4)]),
    T5_lag2 = c(NA, T5_lag[-length(T5)]),
    P1_lag2 = c(NA, P1_lag[-length(P1)]),
    P2_lag2 = c(NA, P2_lag[-length(P2)]),
    Cx_lag2 = c(NA, Cx_lag[-length(Cx)]),
    Cy_lag2 = c(NA, Cy_lag[-length(Cy)]),
    Markerkleur_lag2 = c(NA, Markerkleur_lag[-length(Markerkleur)]),
    TDCG_lag2 = c(NA, TDCG_lag[-length(TDCG)]),
    TDCGkleur_lag2 = c(NA, TDCGkleur_lag[-length(TDCGkleur)])
  )
  
  mDf_lag_3 <- plyr::ddply(
    mDf_lag_2,
    .(UN),
    transform,
    # This assumes that the data is sorted
    H2_lag3 = c(NA, H2_lag2[-length(H2)]),
    CH4_lag3 = c(NA, CH4_lag2[-length(CH4)]),
    C2H6_lag3 = c(NA, C2H6_lag2[-length(C2H6)]),
    C2H4_lag3 = c(NA, C2H4_lag2[-length(C2H4)]),
    C2H2_lag3 = c(NA, C2H2_lag2[-length(C2H2)]),
    CO_lag3 = c(NA, CO_lag2[-length(CO)]),
    
    H2T4_lag3 = c(NA, H2T4_lag2[-length(H2T4)]),
    C2H6T4_lag3 = c(NA, C2H6T4_lag2[-length(C2H6T4)]),
    CH4T4_lag3 = c(NA, CH4T4_lag2[-length(CH4T4)]),
    
    CH4T5_lag3 = c(NA, CH4T5_lag2[-length(CH4T5)]),
    C2H6T5_lag3 = c(NA, C2H6T5_lag2[-length(C2H6T5)]),
    C2H4T5_lag3 = c(NA, C2H4T5_lag2[-length(C2H4T5)]),
    
    CH4T1_lag3 = c(NA, CH4T1_lag2[-length(CH4T1)]),
    C2H4T1_lag3 = c(NA, C2H4T1_lag2[-length(C2H4T1)]),
    C2H2T1_lag3 = c(NA, C2H2T1_lag2[-length(C2H2T1)]),
    
    # Pentagons
    H2P1_lag3 = c(NA, H2P1_lag2[-length(H2P1)]),
    CH4P1_lag3 = c(NA, CH4P1_lag2[-length(CH4P1)]),
    C2H2P1_lag3 = c(NA, C2H2P1_lag2[-length(C2H2P1)]),
    
    C2H4P1_lag3 = c(NA, C2H4P1_lag2[-length(C2H4P1)]),
    C2H6P1_lag3 = c(NA, C2H6P1_lag2[-length(C2H6P1)]),
    # Others
    T1_lag3 = c(NA, T1_lag2[-length(T1)]),
    T4_lag3 = c(NA, T4_lag2[-length(T4)]),
    T5_lag3 = c(NA, T5_lag2[-length(T5)]),
    P1_lag3 = c(NA, P1_lag2[-length(P1)]),
    P2_lag3 = c(NA, P2_lag2[-length(P2)]),
    Cx_lag3 = c(NA, Cx_lag2[-length(Cx)]),
    Cy_lag3 = c(NA, Cy_lag2[-length(Cy)]),
    Markerkleur_lag3 = c(NA, Markerkleur_lag2[-length(Markerkleur)]),
    TDCG_lag3 = c(NA, TDCG_lag2[-length(TDCG)]),
    TDCGkleur_lag3 = c(NA, TDCGkleur_lag2[-length(TDCGkleur)])
  )
  ## Paste added columns back to original dataframe
  sCol_original <- dim(d)[2]
  sCol_transformed <- dim(mDf_lag_3)[2]
  mDf <-
    cbind(data, mDf_lag_3[, (sCol_original + 1):sCol_transformed])
  
  return(mDf)
}

set_colum_types <- function(full_data){
  vFactors <- c('Merk','OlieSoort','MarkerKleur')
  
  ### Three step merge from here: (1) Index column (=UN), (2) One-hot encoded factors (3) Remaing numeric variables
  mFactors <- full_data[ , which(names(full_data) %in% vFactors)]
  # Make each character column a factor per column (else the data will summarize all columns together)
  for (k in 1:NCOL(mFactors)){
    if (k == 1){
      mOh <- mltools::one_hot(data.table::data.table(factor(mFactors[,k])))
    }else{
      mOh <- cbind(mOh,mltools::one_hot(data.table::data.table(factor(mFactors[,k]))))
    }
  }
  mNumeric <- full_data[ , -which(names(full_data) %in% vFactors)]
  mDf_xgboost <- cbind(mNumeric,as.matrix(mOh))
  return(mDf_xgboost)
}

xgboost_data <- function(full_data, Y){
  
  # Variabelen =: X + Y
  variablen <- c("UN","H2","C2H6",
                 "C2H4","CH4","C2H2","CO","TDCGkleur",
                 "C3H8_propaan_ul_p_l","C3H6_propeen_ul_p_l",
                 "CO2_kooldioxide_ul_p_l","O2_zuurstof_ul_p_l",
                 "N2_stikstof_ul_p_l","grensvlakspanning_mN_p_m",
                 "zuurgetal_g_KOH_p_kg","soorslagspanning_kV","tg_delta_x10_4",
                 "specifieke_weerstand_G_Ohm_m","water_gementen_mg_p_kg",
                 "H2T4","C2H6T4","CH4T4","CH4T5","C2H6T5","C2H4T5","CH4T1",
                 "C2H4T1","C2H2T1","H2P1","CH4P1","C2H2P1","C2H4P1",
                 "C2H6P1","T1","T4","T5","P1","P2","Cx","Cy","P90","P9095",
                 "P9599","P99","Markerkleur","TDCG")
  full_data <- set_colum_types(full_data)
  set.seed(42)
  rows <- sample(nrow(full_data))
  full_data <- full_data[rows, ]
  # Selectie =: Variabelen - Y = X
  selectie <- variablen[!variablen %in% Y]
  ## Verwijder alle huidige variablen die niet in de analyse thuishoren. I.e., alleen de lags blijven van X
  keep_from_full<-full_data[ , -which(names(full_data) %in% selectie)]
  
  # Definieer de afhankelijke variable. In andere woorden, de variabele waar de interesse naar uitgaat.
  labels<-as.matrix(keep_from_full[c(Y)])
  
  ## Definieer de onafhankelijke/exogene variabelen voor de analyse.
  vars <-keep_from_full[ , -which(names(keep_from_full) %in% c(Y))]
  
  ## Create train/test data samples
  nn <- as.numeric(NCOL(labels))
  tt <- as.numeric(NROW(labels))
  
  split <- round(as.numeric(tt*.60),0)
  
  # X
  feats <- data.matrix(vars)
  
  ## Full sample
  train_l<-labels[1:split]
  test_l<-labels[(split+1):tt]
  train_f<-feats[1:split,]
  test_f<-feats[(split+1):tt,]
  
  ## Make XGboost data matrix
  train_1 <- xgboost::xgb.DMatrix(data = train_f, label = train_l)
  test_1 <- xgboost::xgb.DMatrix(data = test_f, label = test_l)
  
  # return(train_1)
  training_set <- train_1
  testing_set <- test_1
  
  mData_xgboost <- list(training_set = train_1,testing_set = test_1)
  result <- list(mData = mData_xgboost, UN = full_data$UN, sSplit = split, mTest_data = feats)
  return(result)
}

voorspel_dga <- function(data) {
  # Create xgboost type matrices
  mData_xg_h2 <- xgboost_data(data, Y = 'H2')
  mData_xg_ch4 <- xgboost_data(data, Y = 'CH4')
  mData_xg_c2h6 <- xgboost_data(data, Y = 'C2H6')
  mData_xg_c2h4 <- xgboost_data(data, Y = 'C2H4')
  mData_xg_c2h2 <- xgboost_data(data, Y = 'C2H2')
  # Create forecasts
  vH2 <- voorspel(mData_xg_h2, Y = 'H2')
  vCH4 <- voorspel(mData_xg_ch4, Y = 'CH4')
  vC2H6 <- voorspel(mData_xg_c2h6, Y = 'C2H6')
  vC2H4 <- voorspel(mData_xg_c2h4, Y = 'C2H4')
  vC2H2 <- voorspel(mData_xg_c2h2, Y = 'C2H2')
  indec <- mData_xg_h2$UN
  # Return output with UN
  mForecast <-
    cbind(
      mData_xg_h2$UN,
      vH2$voorspelling,
      vCH4$voorspelling,
      vC2H6$voorspelling,
      vC2H4$voorspelling,
      vC2H2$voorspelling
    )
  colnames(mForecast) <- c('UN', 'H2', 'CH4', 'C2H6', 'C2H4', 'C2H2')
  mForecast_sort <- as_tibble(mForecast)
  mForecast_sort <- mForecast_sort %>% arrange(UN)
  return(list(mForecast = mForecast_sort, mForecast_raw = mForecast))
}

voorspelling_2_numeric <- function(vData, Y){
  if (Y == 'H2'){
    sLevels = c(0,3.5,5,7.5,10, 30, 88,210,1070,2140)
  }else if (Y == 'CH4'){
    sLevels = c(0,2.5,5,7.5,10, 30, 24,59,322,644)
    
  }else if(Y=='C2H6'){
    sLevels = c(0,0.5,1.5,3, 10, 24,38,123,659,1320)
    
  }else if(Y == 'C2H4'){
    sLevels = c(0,0.5,2,3, 10, 24,61,90,720,1440)
    
  }else if (Y == 'C2H2'){
    sLevels = c(0,0.5,2,3, 10, 20,27,90,182,360)
    
  }
  vForecast <- matrix(NA,nrow=NROW(vData),ncol=1)
  i = 1
  for (i in 1:NROW(vData)){
    sFloor <- floor(vData[i]) + 1
    sCeil <- ceiling(vData[i]) + 1
    sDecimal <- vData[i] - floor(vData[i])
    vForecast[i] <- round((sLevels[sFloor] + (sLevels[sCeil] - sLevels[sFloor])*sDecimal),4)
  }
  
  return(vForecast)
}

voorspel <- function(data_xgboost, Y){
  mPredict_data <- data_xgboost$mTest_data
  data_xgboost <- data_xgboost[[1]]
  model_name <- paste0('../models/',Y,'.model')
  bst <- xgb.load(model_name)
  forecast <- voorspelling_2_numeric(predict(bst,mPredict_data), Y = Y)
  return(list(Model = bst, voorspelling = forecast))
}

transform_data <- function(data) {
  #data = readxl::read_excel('./api/tests/single_trafo.xlsx')
  #expected_columns
  #if (!all(expected_columns %in% colnames(df)))
  #  stop("Niet alle kolommen zijn aanwezig in het aangeleverde bestand")
  
  values = create_duval_features(data)
  df_feat = create_features(values)
  print(voorspel_dga(df_feat))
}

#* @apiTitle Plumber Example API

#* @post /predict_dga
#* @param f:file
#* @param sheet:str
function(f, sheet) {
  tmp <- tempfile("plumb", fileext = paste0("_", basename(names(f))))
  on.exit(unlink(tmp))
  writeBin(f[[1]], tmp)
  t <- readxl::read_excel(tmp, trim_ws = TRUE, na = c("", "NA"))
  
  #print(getwd())
  # print(t)
  print(transform_data(t))
  #return(transform_data(t))
}


#* Echo back the input
#* @param msg The message to echo
#* @get /echo
function(msg = "") {
  list(msg = paste0("The message is: '", msg, "'"))
}

#* Plot a histogram
#* @png
#* @get /plot
function() {
  rand <- rnorm(100)
  hist(rand)
}

#* Return the sum of two numbers
#* @param a The first number to add
#* @param b The second number to add
#* @post /sum
function(a, b) {
  as.numeric(a) + as.numeric(b)
}
