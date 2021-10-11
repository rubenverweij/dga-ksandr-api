# DGA-KSANDR-API

Deze api is ontwikkeld in opdracht van KSANDR. Op basis van beschikbare DGA meetwaarden wordt een voorspelling gedaan van de verwachte parts per million (ppm) waarden van vijf sleutelgassen (C2H2, C2H4, C2H6, CH4, H2) en het risicoprofiel. De achterliggende modellen zijn ontwikkeld door studenten in opdracht van KSANDR (voor meer achtergrond zie de documentatie van de DGA tool).

# Inhoudsopgave
1. [Gebruik api](#use)
2. [Installatie R en Docker](#install)
3. [Data transformaties](#data)
4. [Uitleg repository](#repo)
5. [Beheer api](#beheer)

## Gebruik <a name="use"></a>

Wanneer de api container applicatie draait kan een request worden gedaan op het gedefineerde endpoint (voorbeeld):

#### POST excel format

```bash
curl -X POST "http://127.0.0.1:8000/voorspelling" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "f=@single_trafo.xlsx;type=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
```

#### POST json format

```bash
curl -X POST "http://127.0.0.1:8000/voorspelling" <json> -H "accept: application/json"
```

Het format van de json in de POST request:

```json
[{
        "H2": 14.5,
        "CH4": 1,
        "C2H6": 1,
        "C2H4": 1,
        "C2H2": 0.2,
        "CO": 57,
        "SerieNr.": "102630",
        "Merk": "SGB",
        "Bouwjaar": "0905",
        "OlieSoort": "Nytro Taurus",
        "Datum": "20090616",
        "C3H8_propaan_ul_p_l": 10,
        "C3H6_propeen_ul_p_l": 10,
        "C4H10n_norm_butaan_ul_p_l": 0,
        "C4H10i_iso_butaan_ul_p_l": 0,
        "CO2_kooldioxide_ul_p_l": 270,
        "O2_zuurstof_ul_p_l": 16000,
        "N2_stikstof_ul_p_l": 49900,
        "zuurgetal_g_KOH_p_kg": 0.01
    }, {
        "H2": 15.8,
        "CH4": 1.35,
        "C2H6": 0.19,
        "C2H4": 0.15,
        "C2H2": 0.2,
        "CO": 120,
        "SerieNr.": "102630",
        "Merk": "SGB",
        "Bouwjaar": "0905",
        "OlieSoort": "Nytro Taurus",
        "Datum": "20100825",
        "C3H8_propaan_ul_p_l": 16,
        "C3H6_propeen_ul_p_l": 10,
        "C4H10n_norm_butaan_ul_p_l": 0,
        "C4H10i_iso_butaan_ul_p_l": 0,
        "CO2_kooldioxide_ul_p_l": 100,
        "O2_zuurstof_ul_p_l": 16600,
        "N2_stikstof_ul_p_l": 91100,
        "zuurgetal_g_KOH_p_kg": 0.01
    }]
```

De response (ppm waarden voor de sleutelgassen en een risicoscore per serienummer):

```json
[
  {
    "UN": "102630",
    "H2": 29.2555,
    "CH4": 139.6803,
    "C2H6": 41.0745,
    "C2H4": 67.0762,
    "C2H2": 4.196,
    "Risico": 99.95
  },
  {
    "UN": "102631",
    "H2": 29.7297,
    "CH4": 171.5395,
    "C2H6": 48.3307,
    "C2H4": 70.0638,
    "C2H2": 4.2453,
    "Risico": 99.85
  }
]
```


## Installatie <a name="install"></a>

### Installeren Docker

Voordat je Docker kan installeren moeten we de Docker repository configureren.

```bash
 sudo apt-get update

 sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

Voeg de GPG key van Docker toe:
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
Configureer de repository.
```bash
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Installeer Docker en test de "hello world" container.

```bash
 sudo apt-get update
 sudo apt-get install docker-ce docker-ce-cli containerd.io
 sudo docker run hello-world
```

Gebruik docker als non root gebruiker:

```
 sudo groupadd docker
 sudo usermod -aG docker $USER
 newgrp docker
```

### Installeren R 

Voeg CRAN toe als repository.

```bash
# update indices
apt update -qq
# install two helper packages we need
apt install --no-install-recommends software-properties-common dirmngr
# import the signing key (by Michael Rutter) for these repo
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
```

Vervolgens kan R geinstalleerd worden:

```bash
apt install --no-install-recommends r-base
```

## Data transformaties <a name="data"></a>

Op de ruwe data worden de volgende transformaties gedaan:

```r
# De kolomnamen die de DGA tool gebruikt zijn anders dan in de ruwe data
  
  # Stedin
  KolomnummerH2 <<- 26
  KolomnummerCH4 <<- 27
  KolomnummerC2H6 <<- 28
  KolomnummerC2H4 <<- 29
  KolomnummerC2H2 <<- 30
  KolomnummerCO <<- 35
  KolomnummerBedrijfnummer <<- 2
  KolomnummerApparaatsoort <<- 4
  KolomnummerSerieNummer <<- 6
  KolomnummerMerk <<- 7
  KolomnummerPlaats <<- 8
  KolomnummerEigenNummer <<- 9
  KolomnummerBouwjaar <<- 10
  KolomnummerOlieCode <<- 11
  KolomnummerOlieNaam <<- 12
  KolomnummerOlieSoort <<- 13
  KolomnummerCategorie <<- 14
  KolomnummerDatum <<- 22
  KolomnummerAftappunt <<- 24
  
  # Tennet
  KolomnummerH2 <<- 24
  KolomnummerCH4 <<- 25
  KolomnummerC2H6 <<- 26
  KolomnummerC2H4 <<- 27
  KolomnummerC2H2 <<- 28
  KolomnummerCO <<- 33
  KolomnummerBedrijfnummer <<- 16
  KolomnummerApparaatsoort <<- 2
  KolomnummerSerieNummer <<- 4
  KolomnummerMerk <<- 5
  KolomnummerPlaats <<- 6
  KolomnummerEigenNummer <<- 7
  KolomnummerBouwjaar <<- 8
  KolomnummerOlieCode <<- 9
  KolomnummerOlieNaam <<- 10
  KolomnummerOlieSoort <<- 11
  KolomnummerCategorie <<- 12
  KolomnummerDatum <<- 20
  KolomnummerAftappunt <<- 22
  
  # Enexis
  KolomnummerH2 <<- 27
  KolomnummerCH4 <<- 28
  KolomnummerC2H6 <<- 29
  KolomnummerC2H4 <<- 30
  KolomnummerC2H2 <<- 31
  KolomnummerCO <<- 36
  KolomnummerBedrijfnummer <<- 2
  KolomnummerApparaatsoort <<- 4
  KolomnummerSerieNummer <<- 6
  KolomnummerMerk <<- 7
  KolomnummerPlaats <<- 8
  KolomnummerEigenNummer <<- 9
  KolomnummerBouwjaar <<- 10
  KolomnummerOlieCode <<- 11
  KolomnummerOlieNaam <<- 12
  KolomnummerOlieSoort <<- 13
  KolomnummerCategorie <<- 14
  KolomnummerDatum <<- 23
  KolomnummerAftappunt <<- 25
  
  # DNWG
  KolomnummerH2 <<- 26
  KolomnummerCH4 <<- 27
  KolomnummerC2H6 <<- 28
  KolomnummerC2H4 <<- 29
  KolomnummerC2H2 <<- 30
  KolomnummerCO <<- 35
  KolomnummerBedrijfnummer <<- 2
  KolomnummerApparaatsoort <<- 4
  KolomnummerSerieNummer <<- 6
  KolomnummerMerk <<- 7
  KolomnummerPlaats <<- 8
  KolomnummerEigenNummer <<- 9
  KolomnummerBouwjaar <<- 10
  KolomnummerOlieCode <<- 11
  KolomnummerOlieNaam <<- 12
  KolomnummerOlieSoort <<- 13
  KolomnummerCategorie <<- 14
  KolomnummerDatum <<- 22
  KolomnummerAftappunt <<- 24

  # deze transformatie vervangt het kleiner dan teken: "<" voor "" van de volgende kolommen:
  # dus "<3" wordt "3"
  
   $ H2                       : chr [1:18] "14.5" "15.8" "12.4" "10.8" ...
   $ CH4                      : chr [1:18] "<1" "1.35" "4.8" "1.59" ...
   $ C2H6                     : chr [1:18] "<1" "0.19" "0.14" "0.18" ...
   $ C2H4                     : chr [1:18] "<1" "<0.1" "<0.1" "<0.1" ...
   $ C2H2                     : chr [1:18] "<1" "<0.2" "<0.2" "<0.2" ...
   $ CO                       : chr [1:18] "57" "120" "145" "138" ...
   
   vDim_string_numeric <- dim(df[c(KolomnummerH2,KolomnummerCH4,KolomnummerC2H6,KolomnummerC2H4,KolomnummerC2H2,KolomnummerCO)])
df[c(KolomnummerH2,KolomnummerCH4,KolomnummerC2H6,KolomnummerC2H4,KolomnummerC2H2,KolomnummerCO)] <- matrix(as.numeric(gsub("<", "", as.matrix(df[c(KolomnummerH2,KolomnummerCH4,KolomnummerC2H6,KolomnummerC2H4,KolomnummerC2H2,KolomnummerCO)]))),nrow=vDim_string_numeric[1],ncol=vDim_string_numeric[2])

# De kolommen worden hernoemd
colnames(df)[KolomnummerH2] <- "H2"
colnames(df)[KolomnummerCH4] <- "CH4"
colnames(df)[KolomnummerC2H6] <- "C2H6"
colnames(df)[KolomnummerC2H4] <- "C2H4"
colnames(df)[KolomnummerC2H2] <- "C2H2"
colnames(df)[KolomnummerCO] <- "CO"
colnames(df)[KolomnummerAftappunt] <- "Aftappunt"
colnames(df)[KolomnummerMerk] <- "Merk"

# NA waarden worden gefilterd
df <- subset(df, !(H2 == "NA" | CH4 == "NA" | C2H6 == "NA" | C2H4 == "NA" | C2H2 == "NA" ))

# Aleen Aftappunt == "o" blijft over
df <- subset(df, Aftappunt == "o")

# Het datumveld wordt omgezet naar een datum format "%d-%m-%Y"
df[,KolomnummerDatum] <- as.Date(df[,KolomnummerDatum,drop = TRUE], format= "%Y%m%d")
df[,KolomnummerDatum] <- strftime(df[,KolomnummerDatum, drop =TRUE], "%d-%m-%Y")
df[,KolomnummerDatum] <- as.Date( as.character(df[,KolomnummerDatum, drop =TRUE]), "%d-%m-%Y")

# De kolommen worden hernoemd
colnames(df)[KolomnummerDatum] <- "Datum"
colnames(df)[KolomnummerSerieNummer] <- "SerieNr."
colnames(df)[KolomnummerEigenNummer] <- "EigenNr."
colnames(df)[KolomnummerPlaats] <- "Plaats"
colnames(df)[KolomnummerBouwjaar] <- "Bouwjaar"
colnames(df)[1] <- "UN"
colnames(df)[KolomnummerOlieCode] <- "OlieCode"
colnames(df)[KolomnummerOlieNaam] <- "olieNaam"
colnames(df)[KolomnummerOlieSoort] <- "OlieSoort"
colnames(df)[KolomnummerCategorie] <- "Categorie"

# Aleen datums > "2000-01-01" worden behouden
df <- subset(df, Datum >= as.Date("2000-01-01"))
df[,KolomnummerDatum] <- strftime(df[,KolomnummerDatum, drop =TRUE], "%d-%m-%Y")

# Het bouwjaar wordt omgezet naar een nieuw format YYYY b.v. 2011
df <- within(df, Bouwjaar[!is.na(Bouwjaar) &  substr(Bouwjaar, 1, 2) < 30] <-
               paste("20", substr(Bouwjaar[!is.na(Bouwjaar) &  substr(Bouwjaar, 1, 2) < 30] , 1, 2), sep = ""))
df <- within(df, Bouwjaar[!is.na(Bouwjaar) &  substr(Bouwjaar, 1, 2) >= 30] <-
               paste("19", substr(Bouwjaar[!is.na(Bouwjaar) &  substr(Bouwjaar, 1, 2) >= 30] , 1, 2), sep = ""))

# Alleen metingen met data$apparaat_soort ongelijk aan 'sl' overhouden
data[ which(data$apparaat_soort != 'sl'), ]
```

Waarden die zijn toegestaan per variable:

```r
# Toegestane merken (kolom merk)
# > unique(c(unique(mDf_tennet$Merk), unique(mDf_enexis$Merk), unique(mDf_stedin$Merk)))
 [1] "BBC"              "Smit"             "Elin"             "ASEA"             "ACEC"             "AEG"             
 [7] "Oerlikon"         "Ritz"             "Balteau"          "ABB"              "SGB"              "CGS"             
[13] "Alstom"           "Trafo-Union"      "M.W.B."           "Siemens"          "Savoisienne"      "AEI"             
[19] "Merlin-Gerin"     "Pauwels"          "Merk onbekend"    "C.G.E."           "Trench"           "Haefely"         
[25] "Arteche"          "I.E.O."           "Tironi"           "COQ"              "Dietze-Afunk"     "Lepper"          
[31] "ETRA"             "AREVA"            "Tamini"           "Helmke"           "HOLEC"            "Ganz"            
[37] "BEZ"              "Ansaldo"          "English Electric" "MTC"              "Junker"           "Babcock"         
[43] "HTT"              "Toshiba"          "CEM"              "SEA"              "Crompton Greaves" "Schorch"         
[49] "StemTr-Schneider" "Dominit"          "Best Trafo"       "EBG"              "Fr. Transfo"      "Volta-Werke" 

# Toegestane oliesoorten (kolom OlieSoort)
# > unique(c(unique(mDf_tennet$OlieSoort), unique(mDf_enexis$OlieSoort), unique(mDf_stedin$OlieSoort)))
 [1] "Diala D"               "Diala C"               "Diala B"               "Diala S2 ZU-I"         NA                     
 [6] "Nytro Taurus"          "Diala GX"              "Nytro 10 XN"           "Nytro 10 GBN"          "US 3000 P"            
[11] "Diala G"               "Transformer Oil TR 26" "Diekan 1500 N"         "Univolt 62"            "Diala S3 ZX-I"        
[16] "Diala S4 ZX-I"         "Nytro 3000"            "Nytro Libra"           "Diala M"               "Nytro Gemini X"       
[21] "7131"

# Toegestane Markerkleur
> unique(c(unique(mDf_tennet$Markerkleur), unique(mDf_enexis$Markerkleur), unique(mDf_stedin$Markerkleur)))
labels = c("green" = 1,"orange"= 2,"red" = 3,"purple" = 4))

```

## Uitleg Repository <a name="repo"></a>

1.  `config`: configuratiebestanden en globale variabelen
2.  `src`: source code DGA tool en api
3.  `models`: DGA xgboost modellen
4.  `tests`: test data



## Beheer api <a name="beheer"></a>


### Bouwen image en draaien api-server

Doorloop de volgende stappen:

1.  Clone de repository.
2.  Zorg ervoor dat R en Docker zijn geinstalleerd (zie hoofdstuk installatie).
3.  Doorloop de onderstaande stappen:

```bash
# Bouw vervolgens eerst de image:
docker build api/ -t dga/1.0

# Controleer het `IMAGE_ID`:
docker images

# Start de container
docker run --rm -p 8000:8000 IMAGE_ID

# Controleer of de container applicatie draait
docker ps

# Breng de container down (vind het ID door "docker ps" te gebruiken)
docker stop CONTAINER_IDs
```
