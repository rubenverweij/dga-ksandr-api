FROM rstudio/plumber
RUN R -e "install.packages('remotes')"
RUN R -e "remotes::install_version('Rcpp', version='1.0.6')"
RUN R -e "remotes::install_version('mltools', version='0.3.5')"
RUN R -e "remotes::install_version('readxl', version='1.3.1')"
RUN R -e "remotes::install_version('tidyr', version='1.1.3')"
RUN R -e "remotes::install_version('xgboost', version='1.3.2.1')"
RUN R -e "remotes::install_version('plyr', version='1.8.6')"
RUN R -e "remotes::install_version('jsonlite', version='1.7.2')"
RUN R -e "remotes::install_version('data.table', version='1.14.0')"
RUN R -e "remotes::install_version('lubridate', version='1.7.10')"
RUN R -e "install.packages('stringr')"
ADD src /src
ADD log /log
ADD config /config
ADD models /models
ADD tests /tests
CMD ["/src/main.R"]