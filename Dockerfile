## Kaldi Pop Up Archive Image
FROM ubuntu:16.04
MAINTAINER Steve McLaughlin <stephen.mclaughlin@utexas.edu>

ENV PYTHONWARNINGS="ignore:a true SSLContext object"

RUN apt-get update && \
            apt-get install -y g++ zlib1g-dev make automake libtool-bin git autoconf && \
            apt-get install -y subversion libatlas3-base bzip2 wget python2.7 && \
            ln -s /usr/bin/python2.7 /usr/bin/python && \
            ln -s -f bash /bin/sh


## Setting UTF-8 as default encoding format for terminal
#RUN apt-get install -y language-pack-en
#ENV LANG en_US.UTF-8
#ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8

## Installing FFmpeg
#RUN add-apt-repository ppa:jonathonf/ffmpeg-3 \
#&& apt -y update \
#&& apt install -y ffmpeg libav-tools x264 x265

## Installing Perl dependencies
#RUN curl -L http://cpanmin.us | perl - App::cpanminus && cpanm File::Slurp::Tiny Data::Dump

#WORKDIR /home

##

#RUN git clone https://github.com/kaldi-asr/kaldi.git kaldi --origin upstream && \
#cd kaldi/tools && make

#RUN cd /home/kaldi/src && ./configure && make depend && make

#RUN cd /home/kaldi/ && git clone https://github.com/popuparchive/american-archive-kaldi

#RUN cd /home/kaldi/american-archive-kaldi/sample_experiment/ \
#&& wget https://sourceforge.net/projects/popuparchive-kaldi/files/exp2.tar.gz \
#&& tar -xvzf exp2.tar.gz

#RUN ln -s /home/kaldi/egs/wsj/s5/steps /home/kaldi/american-archive-kaldi/sample_experiment/exp
#RUN ln -s /home/kaldi/egs/wsj/s5/utils /home/kaldi/american-archive-kaldi/sample_experiment/exp

#RUN ln -s /home/kaldi/egs/wsj/s5/steps /home/kaldi/american-archive-kaldi/sample_experiment/
#RUN ln -s /home/kaldi/egs/wsj/s5/utils /home/kaldi/american-archive-kaldi/sample_experiment/

#wget https://sourceforge.net/projects/popuparchive-kaldi/files/exp.zip
