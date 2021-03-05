FROM alpine:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apk --update upgrade \
 && apk add \
  bash \
  curl \
  file \
  nano \
  rsync \
  wget \
 && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN echo "====== INSTALL BUILD TOOLS ======" \
 && apk --update add \
  alpine-sdk \
  binutils-gold \
  cmake \
  g++ git git-lfs \
  musl-dev \
  ninja \
  subversion \
 && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN echo "====== INSTALL DOXYGEN TOOLS ======" \
 && apk --update add \
  dia doxygen \
  graphviz \
  imagemagick \
  librsvg \
  py3-jinja2 py3-pygments \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test* \
 && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

ENV PATH=/opt/m.css/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build && cd /tmp/build \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
