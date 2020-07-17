FROM alpine:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV PATH=/opt/m.css/bin:$PATH

RUN echo "====== INSTALL PACKAGES ======" \
 && apk --update upgrade \
 && apk add \
   alpine-sdk \
   cmake curl \
   dia doxygen \
   git git-lfs graphviz \
   imagemagick \
   librsvg \
   ninja \
   py3-jinja2 py3-pygments \
   subversion \
   unzip \
   wget \
 && rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

RUN echo "====== INSTALL M.CSS ======" \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test*