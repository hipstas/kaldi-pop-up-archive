## Kaldi Pop Up Archive Image
FROM ubuntu:16.04
MAINTAINER Steve McLaughlin <stephen.mclaughlin@utexas.edu>

ENV PYTHONWARNINGS="ignore:a true SSLContext object"

ENV SHELL /bin/bash

## Installing core system dependencies
RUN apt-get update && \
apt-get install -y \
g++ zlib1g-dev make automake libtool-bin git autoconf build-essential && \
apt-get install -y \
software-properties-common subversion libatlas3-base bzip2 wget curl \
libperl4-corelibs-perl libjson-perl python2.7 && \
ln -s /usr/bin/python2.7 /usr/bin/python && \
ln -s -f bash /bin/sh

## Installing Perl dependencies
RUN curl -L http://cpanmin.us | perl - App::cpanminus && cpanm File::Slurp::Tiny Data::Dump

## Setting UTF-8 as default encoding format for terminal
RUN apt-get install -y language-pack-en
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## Installing FFmpeg and SoX
RUN add-apt-repository ppa:jonathonf/ffmpeg-3 && apt -y update \
&& apt install -y ffmpeg libav-tools x264 x265
RUN apt-get update && apt-get install -y \
sox libsox-fmt-alsa libsox-fmt-base libsox2

## Installing Kaldi
RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream && \
cd kaldi/tools && make && \
cd /kaldi/src && ./configure && make depend && make

## Downloading Kaldi model files from Pop Up Archive/American Archive of Public Broadcasting
RUN cd /kaldi/ && git clone https://github.com/popuparchive/american-archive-kaldi
RUN cd /kaldi/american-archive-kaldi/sample_experiment/ && \
wget https://sourceforge.net/projects/popuparchive-kaldi/files/exp2.tar.gz && \
tar -xvzf exp2.tar.gz && \
mv exp2 exp
RUN ln -s /kaldi/egs/wsj/s5/steps /kaldi/american-archive-kaldi/sample_experiment/exp && \
ln -s /kaldi/egs/wsj/s5/utils /kaldi/american-archive-kaldi/sample_experiment/exp && \
ln -s /kaldi/egs/wsj/s5/steps /kaldi/american-archive-kaldi/sample_experiment/ && \
ln -s /kaldi/egs/wsj/s5/utils /kaldi/american-archive-kaldi/sample_experiment/

## Installing CMUseg, IRSTLM, and sclite
#RUN sh /kaldi/american-archive-kaldi/sample_experiment/install-cmuseg.sh
#RUN sh /kaldi/tools/extras/install_irstlm.sh
#RUN sh /kaldi/tools/extras/install_sctk_patched.sh
