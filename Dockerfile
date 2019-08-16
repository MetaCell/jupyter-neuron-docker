FROM jupyter/base-notebook:87210526f381

LABEL maintainer="Facundo Rodriguez <facundo@metacell.us>"

# external config
ARG NEURON_VERSION=7.6.2

# configuration
ENV PATH /opt/conda/neuron/x86_64/bin:$PATH 

USER root

# dont install (recommends || suggestions) && avoid debconf warnings
RUN echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf && \
    echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf &&\
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# NEURON requirements
RUN apt-get update &&\
  apt-get install -y \
    automake \
    bison \
    bzip2 \
    ca-certificates \
    curl \
    flex \
    g++ \
    git \
    libncurses-dev \
    libpng-dev \
    libreadline-dev \
    libtool \
    make &&\
  rm -rf /root/.cache &&\
  rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

USER $NB_UID

# install NEURON && some cleaning
RUN mkdir /opt/conda/neuron &&\
  npm config set package-lock 0 &&\
  cd /tmp &&\
  git clone --depth 1 -b $NEURON_VERSION https://github.com/neuronsimulator/nrn &&\
  cd nrn &&\
  ./build.sh &&\
  ./configure \
    --without-x \
    --with-nrnpython=python3 \
    --without-paranrn \
    --prefix='/opt/conda/neuron' \
    --without-iv \
    --without-nrnoc-x11 \
    --silent &&\
  make --silent -j4 &&\
  make --silent install -j4 &&\
  cd src/nrnpython &&\
  python setup.py install &&\
  cd / &&\
  rm -rf /tmp/* &&\
  rm -rf /opt/conda/pkgs &&\
  conda clean -tipsy

RUN conda install --quiet --yes \
  'jupyterhub=1.0.0' && \
  conda clean --all -y

WORKDIR $HOME

EXPOSE 8000

CMD jupyter notebook
