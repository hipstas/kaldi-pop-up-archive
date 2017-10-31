## Kaldi Pop Up Archive Image
FROM ubuntu:16.10
MAINTAINER Steve McLaughlin <stephen.mclaughlin@utexas.edu>

ENV PYTHONWARNINGS="ignore:a true SSLContext object"
ENV SHELL /bin/bash

## Installing core system dependencies
RUN apt-get update && \
apt-get install -y \
g++ zlib1g-dev make automake autoconf libtool-bin git build-essential && \
apt-get install -y \
software-properties-common subversion libatlas3-base bzip2 wget curl gawk \
zip unzip libperl4-corelibs-perl libjson-perl python2.7 python-pip && \
pip install -U ftfy==4.4.3 && \
ln -s -f bash /bin/sh

## Installing old C/C++ compilers
RUN apt-get update && \
apt-get install -y gcc-4.8 g++-4.8 libgcc-4.8-dev && \
alias gcc='gcc-4.8' && alias cc='gcc-4.8' && \
alias g++='g++-4.8' && alias c++='c++-4.8'

## Installing Perl dependencies
RUN curl -L http://cpanmin.us | perl - App::cpanminus && cpanm File::Slurp::Tiny Data::Dump

## Install sctk
RUN apt-get update && apt-get install -y sctk && \
alias sclite="sctk sclite"

## Setting UTF-8 as default encoding format for terminal
RUN apt-get install -y language-pack-en
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## Install Kaldi
RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream && \
cd /kaldi/tools && make && \
cd /kaldi/src && ./configure && make depend && make

## Download PUA resources
RUN cd /kaldi/ && git clone https://github.com/popuparchive/american-archive-kaldi && \
cd /kaldi/american-archive-kaldi/sample_experiment/ && \
wget https://sourceforge.net/projects/popuparchive-kaldi/files/exp2.tar.gz && \
tar -xvzf exp2.tar.gz
