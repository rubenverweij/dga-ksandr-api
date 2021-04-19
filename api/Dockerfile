FROM rstudio/plumber
MAINTAINER Docker User <docker@user.org>

RUN R -e "install.packages('broom')"

CMD ["/app/plumber.R"]