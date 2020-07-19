FROM ubuntu:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive LLVM_MAJOR=10 PATH=/opt/m.css/bin:$PATH
RUN mkdir /usr/local/lib/x86_64-linux-gnu

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -qq install apt-utils \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" dist-upgrade \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   apt-transport-https autoconf automake-1.15 autopoint \
   bison build-essential \
   ca-certificates clang clang-format clang-tidy clang-tools curl \
   dia doxygen-latex \
   flex \
   gawk gettext git git-lfs global gnupg graphviz \
   imagemagick \
   libarchive-tools libc++-dev libc++abi-dev libclang-dev libicu-dev librsvg2-bin libssl-dev libtool libunwind-dev libxml2-dev lld llvm lsb-release \
   mscgen \
   nasm ninja-build \
   python3-distutils python3-jinja2 python3-pygments python3-simplejson python3-six python3-yaml \
   software-properties-common subversion \
   texinfo \
   unzip \
   wget \
   zlib1g-dev \
 && apt-get autoremove -y -q \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL CMAKE ======" \
 && echo "deb [trusted=yes] https://files.nephatrine.net/Packages/Linux ./" >> /etc/apt/sources.list.d/nxbuild.list \
 && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - > /etc/apt/trusted.gpg.d/kitware.gpg \
 && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install cmake cmake-nxbuild kitware-archive-keyring \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/* /etc/apt/trusted.gpg.d/kitware.gpg

RUN echo "====== INSTALL M.CSS ======" \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test*

RUN echo "====== INSTALL NXBUILD SOURCE ======" \
 && mkdir -p /opt/nxb/src && cd /opt/nxb/src \
 && git clone https://code.nephatrine.net/nephatrine/nxbuild.git \
 && rm -rf /tmp/* /var/tmp/*