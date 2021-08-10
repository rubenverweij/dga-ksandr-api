# dga-ksandr-api
Dit project bevat 

## Randvoorwaarden

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