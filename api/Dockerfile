ARG R_VERSION=4.1.2

FROM rocker/r-ver:${R_VERSION}
LABEL maintainer="barret@rstudio.com"

# BEGIN rstudio/plumber layers
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  curl \
  libsodium-dev \
  libxml2-dev

RUN install2.r remotes

## Remove this comment to always bust the Docker cache at this step
## https://stackoverflow.com/a/55621942/591574
#ADD https://github.com/rstudio/plumber/commits/ _docker_cache

ARG PLUMBER_REF=main
RUN Rscript -e "remotes::install_github('rstudio/plumber@${PLUMBER_REF}')"

EXPOSE 8000
ENTRYPOINT ["R", "-e", "pr <- plumber::plumb(rev(commandArgs())[1]); args <- list(host = '0.0.0.0', port = 8000); if (packageVersion('plumber') >= '1.0.0') { pr$setDocs(TRUE) } else { args$swagger <- TRUE }; do.call(pr$run, args)"]

# Copy installed example to default file at ~/plumber.R
ARG ENTRYPOINT_FILE=/usr/local/lib/R/site-library/plumber/plumber/04-mean-sum/plumber.R
RUN cp ${ENTRYPOINT_FILE} ~/plumber.R

CMD ["~/plumber.R"]

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
RUN R -e "remotes::install_version('stringr', version='1.4.0')"
ADD src /src
ADD log /log
ADD config /config
ADD models /models
ADD tests /tests
CMD ["/src/main.R"]