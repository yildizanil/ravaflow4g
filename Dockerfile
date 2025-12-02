FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

RUN cd /tmp && \

    apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:ubuntugis/ubuntugis-unstable -y && \

    apt-get update && \
    apt-get install -y wget unzip build-essential python3-pip && \
    apt-get install -y libgeos-dev libproj-dev proj-data proj-bin libgdal-dev python3-gdal gdal-bin && \
    apt-get install -y grass-dev grass-doc grass-gui && \
    apt-get install -y python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \

    wget https://www.landslidemodels.org/r.avaflow/software/r.avaflow.40G.zip && \
    unzip r.avaflow.40G.zip && \
    cd r.avaflow.40G

RUN python3 -m pip install --upgrade pillow

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \

    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/" && \

    apt-get update && \
    apt-get install -y r-base r-base-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN R -e "install.packages(c('stats', 'codetools', 'Rcpp', 'terra', 'lattice', 'sp', 'raster', 'ROCR'), repos='http://cran.rstudio.com/')"

RUN cd tmp && \

    mkdir ./grass_locations && \
    grass -c XY /tmp/grass_locations/tmp --text && \
    grass /tmp/grass_locations/tmp/PERMANENT --exec g.extension extension=r.avaflow.40G url=/tmp/r.avaflow.40G
    
CMD ["bash"]
