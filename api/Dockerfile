FROM rstudio/plumber
RUN R -e "install.packages('Rcpp')"
RUN R -e "install.packages('mltools')"
RUN R -e "install.packages('readxl')"
RUN R -e "install.packages('tidyr')"
RUN R -e "install.packages('xgboost')"
RUN R -e "install.packages('plyr')"
ADD dga /dga
ADD config /config
ADD models /models
ADD tests /tests
CMD ["/dga/main.R"]