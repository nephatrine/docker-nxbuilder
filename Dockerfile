FROM centos:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV PATH=/opt/m.css/bin:$PATH
COPY override /

RUN echo "====== INSTALL PACKAGES ======" \
 && dnf -y -q install 'dnf-command(config-manager)' epel-release \
 && dnf config-manager --set-enabled PowerTools \
 && dnf update -y -q \
 && dnf -y -q install \
   ImageMagick \
   binutils \
   cmake cmake-NXBuild createrepo curl \
   dia doxygen-latex \
   gcc-c++ git git-lfs glibc-devel graphviz \
   librsvg2-tools \
   ninja-build \
   python3-jinja2 python3-pygments \
   redhat-lsb-core rpm-build \
   subversion \
   unzip \
   wget \
 && dnf autoremove -y -q \
 && dnf clean all \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL M.CSS ======" \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test*