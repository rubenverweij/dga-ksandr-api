# DGA-KSANDR-API

Deze api is ontwikkeld in opdracht van KSANDR. Op basis van beschikbare DGA meetwaarden wordt een voorspelling gedaan van de verwachte parts per million (ppm) waarden van vijf sleutelgassen (C2H2, C2H4, C2H6, CH4, H2) en het risicoprofiel. De achterliggende modellen zijn ontwikkeld door studenten in opdracht van KSANDR (voor meer achtergrond zie de documentatie van de DGA tool).

Er is geen aanpassing gedaan aan de werking van de modellen.

# Inhoudsopgave
1. [Gebruik api](#use)
2. [Beheer api](#beheer)
3. [Installatie R en Docker](#install)
4. [Data transformaties](#data)
5. [Uitleg repository](#repo)


## Gebruik <a name="use"></a>

Wanneer de api container applicatie draait kan een request worden gedaan op het gedefineerde endpoint (voorbeeld):

#### POST excel format

```bash
curl -X POST "http://127.0.0.1:8000/voorspelling_excel" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "f=@test_dnwg_klein.xlsx;type=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
```

#### POST json format

```bash
curl --data @test_metingen.json  http://127.0.0.1:8000/voorspelling_json_file
```

Het format van de json in de POST request:


```json
[{
        "H2": 5.4,
        "CH4": 2.9,
        "C2H6": 1.3,
        "C2H4": 1,
        "C2H2": 1,
        "CO": 75,
        "SerieNr.": "219199",
        "Merk": "Smit",
        "Bouwjaar": "1978",
        "OlieSoort": "Diala B",
        "Datum": "20040527",
        "C4H10n_norm_butaan_ul_p_l": 1.7,
        "C4H10i_iso_butaan_ul_p_l": 1
    }, {
        "H2": 10.7,
        "CH4": 4.1,
        "C2H6": 2.2,
        "C2H4": 1,
        "C2H2": 1,
        "CO": 199,
        "SerieNr.": "219199",
        "Merk": "Smit",
        "Bouwjaar": "1978",
        "OlieSoort": "Diala B",
        "Datum": "20010712",
        "C4H10n_norm_butaan_ul_p_l": 1.5,
        "C4H10i_iso_butaan_ul_p_l": 1
    }, {
        "H2": 5.6,
        "CH4": 3,
        "C2H6": 1.7,
        "C2H4": 1.1,
        "C2H2": 1,
        "CO": 80,
        "SerieNr.": "219199",
        "Merk": "Smit",
        "Bouwjaar": "1978",
        "OlieSoort": "Diala B",
        "Datum": "20030321",
        "C4H10n_norm_butaan_ul_p_l": 1.4,
        "C4H10i_iso_butaan_ul_p_l": 1
    }, {
        "H2": 7.5,
        "CH4": 3.7,
        "C2H6": 2.1,
        "C2H4": 1.1,
        "C2H2": 1,
        "CO": 126,
        "SerieNr.": "219199",
        "Merk": "Smit",
        "Bouwjaar": "1978",
        "OlieSoort": "Diala B",
        "Datum": "20020626",
        "C4H10n_norm_butaan_ul_p_l": 1.8,
        "C4H10i_iso_butaan_ul_p_l": 1
    }
]
```

De response (ppm waarden voor de sleutelgassen en een risicoscore per serienummer):

```json
[
  {
    "UN": "219199",
    "H2": 9.9805,
    "CH4": 4.414,
    "C2H6": 2.7332,
    "C2H4": 2.4367,
    "C2H2": 2.0071,
    "Risico": 0
  }
]
```

## Beheer api <a name="beheer"></a>

Het beheer van de api is eenvoudig. In principe is er geen onderhoud aan de container. Met `docker` kunnen verschillende 
standaard operaties worden gedaan zoals `start` en `stop`. Default starten we de container met een restart policy `--restart unless-stopped`. Dit betekent dat de container altijd weer opstart tenzij hij manueel wordt gestopt. 

De repo bestaat uit de volgende mappen:
1.  `config`: configuratiebestanden en globale variabelen
2.  `src`: source code DGA tool en api
3.  `models`: DGA xgboost modellen
4.  `tests`: test data
5.  `log`: api logging

### Bouwen image en draaien api-server

Doorloop de volgende stappen:

1.  Clone de repository.
2.  Zorg ervoor dat R en Docker zijn geinstalleerd (zie hoofdstuk installatie).
3.  Doorloop de onderstaande stappen:

```bash
# Bouw vervolgens eerst de image:
docker build api/ -t dga/1.0

# Controleer het `<image_id>`:
docker images

# Start de container
docker run -d --restart unless-stopped --net=host -p 8000:8000 <image_id>

# Controleer of de container applicatie draait
docker ps

# Verwijder een image
docker rmi <image_id>

# Breng de container down (vind het ID door "docker ps" te gebruiken)
docker stop <container_id>

# Het updaten van een restart policy voor een draaiende container
docker update --restart unless-stopped redis
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

De features die het model verwacht:

```r
 c("Bouwjaar", "C4H10n_norm_butaan_ul_p_l", "C4H10i_iso_butaan_ul_p_l", 
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

```
