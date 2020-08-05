FROM centos:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== CONFIGURE REPOS ======" \
 && dnf -y -q install \
  'dnf-command(config-manager)' \
  epel-release \
  gnupg \
  wget \
 && dnf config-manager --set-enabled PowerTools \
 && wget -qO /etc/yum.repos.d/NephNET.repo https://files.nephatrine.net/Packages/NephRPM.repo \
 && dnf update -y -q \
  curl \
  file \
  nano \
  rsync \
 && dnf autoremove -y -q \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL BUILD TOOLS ======" \
 && dnf -y -q install \
  binutils \
  cmake createrepo \
  gcc gcc-c++ git git-lfs glibc-devel \
  ninja-build \
  rpm-build rpm-sign \
  subversion \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL DOXYGEN TOOLS ======" \
 && dnf -y -q install \
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
 && wget -qO /etc/yum.repos.d/NephNET.repo https://files.nephatrine.net/Packages/NephRPM.repo \
 && dnf -y -q install \
  ImageMagick \
  cmake-NXBuild \
  librsvg2-tools \
  redhat-lsb-core \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*
