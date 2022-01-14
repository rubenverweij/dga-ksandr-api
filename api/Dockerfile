FROM rstudio/plumber

RUN install2.r --error \
    Rcpp \
    mltools \
    readxl \
    tidyr \
    xgboost \
    plyr \
    jsonlite \
    data.table \
    lubridate \
    stringr
    
ADD src /src
ADD log /log
ADD config /config
ADD models /models
ADD tests /tests
CMD ["/src/main.R"]