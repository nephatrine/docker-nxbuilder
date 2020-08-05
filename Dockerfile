FROM ubuntu:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== CONFIGURE REPOS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  apt-transport-https apt-utils \
  gnupg \
  software-properties-common \
  wget 2>/dev/null \
 && wget -qO - https://files.nephatrine.net/Packages/Nephatrine.gpg | apt-key add - 2>/dev/null \
 && wget -qO /etc/apt/sources.list.d/NephNET.list https://files.nephatrine.net/Packages/NephDEB.list \
 && wget -qO - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - 2>/dev/null \
 && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' \
 && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" dist-upgrade -y \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  curl \
  file \
  nano \
  rsync \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

ENV LLVM_MAJOR=10
RUN echo "====== INSTALL BUILD TOOLS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  build-essential \
  clang clang-format clang-tidy clang-tools cmake \
  git git-lfs \
  kitware-archive-keyring \
  libc++-dev libc++abi-dev libunwind-dev lld llvm \
  ninja-build \
  subversion \
 && apt-get clean \
 && ls /usr/lib/clang/$LLVM_MAJOR \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL DOXYGEN TOOLS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  dia doxygen-latex \
  global graphviz \
  mscgen \
  python3-jinja2 python3-pygments \
 && apt-get autoremove -y -q \
 && apt-get clean \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test* \
 && rm -rf /tmp/* /var/tmp/*
ENV PATH=/opt/m.css/bin:$PATH

RUN echo "====== INSTALL NXBUILD ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  cmake-nxbuild \
  imagemagick \
  librsvg2-bin lsb-release \
 && apt-get clean \
 && mkdir -p /usr/src && cd /usr/src \
 && git clone https://code.nephatrine.net/nephatrine/nxbuild.git \
 && rm -rf /tmp/* /var/tmp/*
COPY override /