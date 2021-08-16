# dga-ksandr-api

Deze api is ontwikkeld in opdracht van KSANDR. Op basis van beschikbare DGA meetwaarden wordt een voorspelling gedaan van de verwachte parts per million (ppm) waarden van vijf sleutelgassen (C2H2, C2H4, C2H6, CH4, H2) De achterliggende modellen zijn ontwikkeld door studenten in opdracht van KSANDR.

1.  `config`: model constanten
2.  `dga`: source code DGA tool en api
3.  `models`: DGA modellen
4.  `tests`: test data

## Gebruik

Zorg ervoor dat R en Docker zijn geinstalleerd (zie hoofdstuk installatie).
Bouw vervolgens eerst de image:

```bash
docker build api/ -t dga/1.0
```

Start de container:

```bash
docker run --rm -p 8000:8000 IMAGE_ID
```

Test de api:

```bash
curl -X POST "http://127.0.0.1:8991/voorspelling" -H "accept: application/json" -H "Content-Type: multipart/form-data" -F "f=@single_trafo.xlsx;type=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
```

De verwachte response zijn de waarden van de sleutelgassen per uniek serienummer:

```bash
[{"UN":"102630","H2":"2.0808","CH4":"1.7275","C2H6":"0.346","C2H4":"0.346","C2H2":"0.3135"},{"UN":"102631","H2":"2.1187","CH4":"1.7691","C2H6":"0.349","C2H4":"0.4405","C2H2":"0.4782"}]
```


## Installatie

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

Manage Docker as a non-root user

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

## Build image

Om het image van de container te bouwen:
```bash
docker build -t api .
```



# Restart container when booting server
https://www.rplumber.io/articles/hosting.html

docker run --rm -p 8000:8000 rstudio/plumber

For instance if you have a plumber file saved in your current directory called api.R, you could use the following command

docker run --rm -p 8000:8000 -v `pwd`/api.R:/plumber.R rstudio/plumber /plumber.R