# Use the latest version of R with support for Linux binaries
FROM rocker/r-ver:4.2.1

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
  # Install XML2
  libxml2-dev  \ 
  # Install the Cairo graphics library
  libcairo2-dev \
  libsqlite-dev \
  libmariadb-dev \ 
  libpq-dev \
  libssh2-1-dev \
  unixodbc-dev \
  libsasl2-dev \
  libgsl0-dev \
  # Needed for curl
  libcurl4-openssl-dev \ 
  # Open SSL
  libssl-dev \
  # Image Magick
  libmagick++-dev \
  # Rust
  cargo \
  # Needed for gifski
  libharfbuzz-dev \
  libfribidi-dev \
  # Needed for Rmarkdown
  pandoc \
  # Remove unneeded files to decrease image size
  && rm -rf /var/lib/apt/lists/*

# Install dependencies for installing bioconductor packages
RUN install2.r --error \
    --ncpus -1 \
    --repos https://ropensci.r-universe.dev --repos getOption \
    --skipinstalled \
    BiocManager littler

# Packages from Bioconductor (will compile from source)
RUN /usr/local/lib/R/site-library/littler/examples/installBioc.r S4Vectors 
RUN /usr/local/lib/R/site-library/littler/examples/installBioc.r biomaRt
RUN /usr/local/lib/R/site-library/littler/examples/installBioc.r  KEGGgraph 
RUN /usr/local/lib/R/site-library/littler/examples/installBioc.r BiocVersion

# Install R packages from CRAN (will download binaries)
# Install igraph first or amd64 build will fail
RUN install2.r --error \
    --deps TRUE \
    --ncpus -1 \
    --repos https://ropensci.r-universe.dev --repos getOption \
    --skipinstalled \
    igraph
RUN install2.r --error \
    --deps TRUE \
    --ncpus -1 \
    --repos https://ropensci.r-universe.dev --repos getOption \
    --skipinstalled \
    rmarkdown \
    knitr \
    readr \
    pander \
    survival \
    rms \
    prodlim \
    riskRegression \ 
    pec \
    glmnet \ 
    survival 

RUN install2.r --error \
    --deps FALSE \
    --ncpus -1 \
    --skipinstalled \
    stabs \
    inum \
    partykit \
    mboost

RUN rm -rf /tmp/downloaded_packages \
    && strip /usr/local/lib/R/site-library/*/libs/*.so   

RUN mkdir Output
RUN mkdir Source
         
WORKDIR /
COPY Docker /
RUN mkdir Data
LABEL org.opencontainers.image.source https://github.com/karlamonterrubiog/competing_risks
CMD Rscript render.R