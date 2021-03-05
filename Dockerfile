FROM centos:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== CONFIGURE REPOS ======" \
 && echo 'install_weak_deps=False' >>/etc/dnf/dnf.conf \
 && dnf -y install \
  'dnf-command(config-manager)' \
  epel-release \
  gnupg \
  wget \
 && dnf -y config-manager --set-enabled powertools \
 && wget -O /etc/yum.repos.d/NephNET.repo https://files.nephatrine.net/Packages/NephRPM-CentOS.repo \
 && dnf upgrade  -y \
 && dnf -y install \
  curl \
  file \
  nano \
  rsync \
 && dnf autoremove -y \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL BUILD TOOLS ======" \
 && dnf -y install \
  binutils \
  cmake createrepo \
  gcc gcc-c++ git git-lfs glibc-devel glibc-devel.i686 \
  libstdc++-devel libstdc++-devel.i686 \
  ninja-build \
  redhat-lsb-core rpm-build rpm-sign \
  subversion \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL DOXYGEN TOOLS ======" \
 && dnf -y install \
  ImageMagick \
  dia doxygen-latex \
  graphviz \
  librsvg2-tools \
  python3-jinja2 python3-pygments \
 && dnf clean all \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test* \
 && rm -rf /tmp/* /var/tmp/*

ENV PATH=/opt/m.css/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-x86_64 && cd /tmp/build-x86_64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.x86_64.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && mkdir /tmp/build-i686 && cd /tmp/build-i686 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.i686.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
