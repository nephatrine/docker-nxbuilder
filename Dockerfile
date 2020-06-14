FROM ubuntu:rolling
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -qq install apt-utils \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   autoconf automake-1.15 autopoint \
   bison build-essential \
   ca-certificates clang clang-format clang-tidy clang-tools cmake curl \
   doxygen-latex dia \
   flex \
   gawk gettext git git-lfs global graphviz \
   libarchive-tools libc++-dev libc++abi-dev libclang-dev libicu-dev libssl-dev libtool libunwind-dev libxml2-dev lld llvm lsb-release \
   mercurial mscgen \
   nasm ninja-build \
   python3-distutils python3-jinja2 python3-pygments python3-simplejson python3-six python3-yaml \
   subversion \
   texinfo \
   unzip \
   wget \
   zlib1g-dev \
 && apt-get clean \
 && mkdir /usr/local/lib/x86_64-linux-gnu \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN echo "====== INSTALL M.CSS ======" \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test*
ENV PATH=/opt/m.css/bin:$PATH

COPY override /

RUN echo "====== INSTALL NXBUILD ======" \
 && mkdir -p /opt/nxb/src && cd /opt/nxb/src \
 && git clone https://code.nephatrine.net/nephatrine/nxbuild.git \
 && mkdir /usr/src/build && cd /usr/src/build \
 && cmake -GNinja /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /usr/src/*