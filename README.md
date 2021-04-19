# dga-ksandr-api
api for DGA tool integration on Ksandr intranet


# Install

1 - Rstudio and R https://www.r-bloggers.com/2013/03/download-and-install-r-in-ubuntu/
2 - Install Docker https://docs.docker.com/engine/install/ubuntu/ 


# Restart container when booting server
https://www.rplumber.io/articles/hosting.html

docker run --rm -p 8000:8000 rstudio/plumber

For instance if you have a plumber file saved in your current directory called api.R, you could use the following command

docker run --rm -p 8000:8000 -v `pwd`/api.R:/plumber.R rstudio/plumber /plumber.R