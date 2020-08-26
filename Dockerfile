FROM centos:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== CONFIGURE REPOS ======" \
 && echo 'install_weak_deps=False' >>/etc/dnf/dnf.conf \
 && dnf -y install \
  'dnf-command(config-manager)' \
  epel-release \
  gnupg \
  wget \
 && dnf config-manager --set-enabled PowerTools \
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
  rpm-build rpm-sign \
  subversion \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL DOXYGEN TOOLS ======" \
 && dnf -y install \
  dia doxygen-latex \
  graphviz \
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

RUN echo "====== INSTALL NXBUILD ======" \
 && dnf -y install \
  ImageMagick \
  cmake-NXBuild \
  librsvg2-tools \
  redhat-lsb-core \
 && dnf clean all \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/nxbuild.git \
 && rm -rf /tmp/* /var/tmp/*
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64.cmake /usr/src/hello \
 && ninja && ninja test \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-ia32.cmake /usr/src/hello \
 && ninja && ninja test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*