FROM jupyter/base-notebook:hub-1.1.0

LABEL maintainer="Facundo Rodriguez <facundo@metacell.us>"

# Fixes ncurses error downstream
RUN conda uninstall --force readline ncurses

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

WORKDIR $HOME

EXPOSE 8000

CMD jupyter notebook
