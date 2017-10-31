## Kaldi Pop Up Archive Container
FROM ubuntu:16.04
MAINTAINER Steve McLaughlin <stephen.mclaughlin@utexas.edu>

ENV PYTHONWARNINGS="ignore:a true SSLContext object"

apt-get update && apt-get install -y \
wget \
acpid \
apport \
apport-symptoms \
arping \
autoconf \
automake \
autotools-dev \
binutils \
biosdevname \
build-essential \
byobu \
cloud-guest-utils \
cloud-image-utils \
cloud-init \
cloud-initramfs-growroot \
cloud-utils \
cpp \
cpp-4.8 \
crda \
cryptsetup \
cryptsetup-bin \
curl \
distro-info \
distro-info-data \
dpkg-dev \
eatmydata \
ethtool \
euca2ools \
fakeroot \
fonts-ubuntu-font-family-console \
g++ \
g++-4.8 \
gawk \
gcc \
gcc-4.8 \
gdisk \
genisoimage \
git \
git-man \
landscape-client \
landscape-common \
libaio1 \
libalgorithm-diff-perl \
libalgorithm-diff-xs-perl \
libalgorithm-merge-perl \
libapr1 \
libaprutil1 \
libasan0 \
libasound2 \
libasound2-data \
libatlas3-base \
libatomic1 \
libblas3 \
libboost-system1.54.0 \
libboost-thread1.54.0 \
libc-dev-bin \
libc6-dev \
libck-connector0 \
libcloog-isl4 \
libcommon-sense-perl \
libcryptsetup4 \
libcurl3 \
libdpkg-perl \
libdumbnet1 \
liberror-perl \
libfakeroot \
libfile-fcntllock-perl \
libflac8 \
libgcc-4.8-dev \
libgfortran3 \
libgmp10 \
libgomp1 \
libgsm1 \
libicu52 \
libisl10 \
libitm1 \
libjson-perl \
libjson-xs-perl \
liblinear-tools \
liblinear1 \
libltdl-dev \
libltdl7 \
liblua5.2-0 \
libmpc3 \
libmpdec2 \
libmpfr4 \
libnet1 \
libnl-3-200 \
libnl-genl-3-200 \
libnspr4 \
libnss-myhostname \
libnss3 \
libnss3-nssdb \
libogg0 \
libopencore-amrnb0 \
libopencore-amrwb0 \
libperl4-corelibs-perl \
libpolkit-agent-1-0 \
libpolkit-backend-1-0 \
libquadmath0 \
librados2 \
librbd1 \
libserf-1-1 \
libsndfile1 \
libsox-fmt-alsa \
libsox-fmt-base \
libsox2 \
libstdc++-4.8-dev \
libsvn1 \
libtool \
libtsan0 \
libvorbis0a \
libvorbisenc2 \
libvorbisfile3 \
libwavpack1 \
libxslt1.1 \
libyaml-0-2 \
linux-firmware \
linux-headers-4.4.0-45 \
linux-headers-4.4.0-45-generic \
linux-headers-generic-lts-xenial \
linux-image-4.4.0-45-generic \
linux-image-extra-4.4.0-45-generic \
linux-image-generic-lts-xenial \
linux-libc-dev \
manpages-dev \
nmap \
openssh-server \
openssh-sftp-server \
overlayroot \
policykit-1 \
pollinate \
python-chardet-whl \
python-cheetah \
python-colorama \
python-colorama-whl \
python-configobj \
python-distlib \
python-distlib-whl \
python-distro-info \
python-gdbm \
python-html5lib \
python-html5lib-whl \
python-json-pointer \
python-jsonpatch \
python-lxml \
python-oauth \
python-openssl \
python-pam \
python-pip \
python-pip-whl \
python-pkg-resources \
python-prettytable \
python-pycurl \
python-requestbuilder \
python-requests \
python-requests-whl \
python-serial \
python-setuptools \
python-setuptools-whl \
python-six-whl \
python-twisted-bin \
python-twisted-core \
python-twisted-names \
python-twisted-web \
python-urllib3 \
python-urllib3-whl \
python-wheel \
python-yaml \
python-zope.interface \
python3-apport \
python3-newt \
python3-pkg-resources \
python3-problem-report \
python3-pycurl \
python3-software-properties \
qemu-utils \
run-one \
screen \
sharutils \
software-properties-common \
sox \
ssh-import-id \
subversion \
tmux \
tree \
unattended-upgrades \
zip \
unzip \
update-notifier-common \
wireless-regdb \
zerofree \
zlib1g-dev

## Setting UTF-8 as default encoding format for terminal
RUN apt-get install -y language-pack-en
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

## Installing FFmpeg
RUN add-apt-repository ppa:jonathonf/ffmpeg-3 \
&& apt -y update \
&& apt install -y ffmpeg libav-tools x264 x265

## Installing Perl dependencies
RUN curl -L http://cpanmin.us | perl - App::cpanminus
RUN cpanm File::Slurp::Tiny Data::Dump


WORKDIR /home

ln -s /home/kaldi/egs/wsj/s5/steps /home/kaldi/american-archive-kaldi/sample_experiment/exp
ln -s /home/kaldi/egs/wsj/s5/utils /home/kaldi/american-archive-kaldi/sample_experiment/exp

ln -s /home/kaldi/egs/wsj/s5/steps /home/kaldi/american-archive-kaldi/sample_experiment/
ln -s /home/kaldi/egs/wsj/s5/utils /home/kaldi/american-archive-kaldi/sample_experiment/
