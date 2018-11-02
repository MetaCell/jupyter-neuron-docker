FROM jupyter/base-notebook:eb70bcf1a292
MAINTAINER Facundo Rodriguez "facundo@metacell.us"
USER root
RUN apt-get -qq update
RUN apt-get install -y \
        locales \
        wget \
        gcc \
        g++ \
        build-essential \
        libncurses-dev \
        libpython-dev \
        cython \
        libx11-dev \
        git \
        bison \
        flex \
        automake \ 
        libtool \ 
        libxext-dev \
        libncurses-dev \
        xfonts-100dpi \ 
        libopenmpi-dev \
        make \
        zlib1g-dev \
        unzip \
        vim \
        libpng-dev
# Switch to non sudo, create a Python 3 virtual environment 
USER $NB_USER
RUN conda create --name snakes python=3.7
# Install latest iv and NEURON
RUN git clone --branch 7.6.2 https://github.com/neuronsimulator/nrn
WORKDIR nrn
RUN ./build.sh
# Activate conda to configure nrn with the right python version
RUN /bin/bash -c "source activate snakes && ./configure --without-x --with-nrnpython=python3 --without-paranrn --prefix='/home/jovyan/work/nrn/' --without-iv"
RUN make --silent -j4
RUN make --silent install -j4
# Install NEURON python
WORKDIR src/nrnpython
ENV PATH="/home/jovyan/work/nrn/x86_64/bin:${PATH}"
RUN /bin/bash -c "source activate snakes && python setup.py install"
WORKDIR ../../../
