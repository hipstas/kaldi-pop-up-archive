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

## Download Kaldi and PUA resources
RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream && \
cd /kaldi/egs/ && git clone https://github.com/popuparchive/american-archive-kaldi && \
cd /kaldi/egs/american-archive-kaldi/sample_experiment/ && \
wget https://sourceforge.net/projects/popuparchive-kaldi/files/exp2.tar.gz && \
tar -xvzf exp2.tar.gz

 RUN rm /kaldi/egs/american-archive-kaldi/sample_experiment/exp2.tar.gz

## Creating expected symlinks
RUN ln -s /kaldi/egs/wsj/s5/steps /kaldi/egs/american-archive-kaldi/sample_experiment/exp && \
ln -s /kaldi/egs/wsj/s5/utils /kaldi/egs/american-archive-kaldi/sample_experiment/exp && \
ln -s /kaldi/egs/wsj/s5/steps /kaldi/egs/american-archive-kaldi/sample_experiment/ && \
ln -s /kaldi/egs/wsj/s5/utils /kaldi/egs/american-archive-kaldi/sample_experiment/

## Installing SoX and FFmpeg
RUN apt-get update && apt-get install -y \
sox libsox-fmt-alsa libsox-fmt-base libsox2 ffmpeg

#### Don't touch above this line, 54. ####


## Install Kaldi
RUN cd /kaldi/tools && make -j 4 && \
cd /kaldi/src && ./configure && make depend && make -j 4



##Python
RUN apt-get update && apt-get install -y python-pip && \
pip install ftfy==4.4.3 && \
alias python=python2.7

## Installing IRSTLM
RUN apt-get update && apt-get install -y cmake irstlm
#RUN cd /kaldi/tools/extras/ && \
#sh install_irstlm.sh

## Installing CMUseg
RUN cd /kaldi/egs/american-archive-kaldi/sample_experiment/ && \
sh install-cmuseg.sh && \
chmod -R 755 ./tools/CMUseg_0.5/bin/linux/

## Setting script permissions
RUN chmod 755 -R /kaldi/egs/american-archive-kaldi/sample_experiment/scripts/
RUN chmod 755 -R /kaldi/egs/american-archive-kaldi/sample_experiment/run.sh

# change first line to point to /kaldi
#/kaldi/egs/american-archive-kaldi/set_kaldi_path.sh
#/kaldi/egs/american-archive-kaldi/path.sh

#pass pathname in docker call to a shell script
#create a temp directory int he shared volume for 16khz files
#convert media files to 16khz & remove troublesome characters
#create an output directory and copy output transcript files to it

#output: /kaldi/egs/american-archive-kaldi/sample_experiment/output
