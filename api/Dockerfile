FROM rstudio/plumber
LABEL ruben.verweij@datapreds.com
RUN R -e "install.packages('broom')"
RUN R -e "install.packages('readxl')"
RUN R -e "nstall.packages('plotly')"
RUN R -e "install.packages('tidyr')"
RUN R -e "install.packages('dplyr')"
RUN R -e "install.packages('zoo')"
RUN R -e "install.packages('DT')"
RUN R -e "install.packages('class')"
RUN R -e "install.packages('writexl')"
RUN R -e "install.packages('devtools')"
RUN R -e "install.packages('caTools')" 
RUN R -e "install.packages('e1071')"
RUN R -e "install.packages('kernlab')"
RUN R -e "install.packages('fpc')"
RUN R -e "install.packages('caret')"
RUN R -e "install.packages('plm')"
RUN R -e "install.packages('plyr')"
RUN R -e "install.packages('chron')"
ADD models /models
ADD tests /tests
CMD ["/dga/plumber.R"]