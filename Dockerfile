FROM ubuntu:rolling
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -qq install apt-utils \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   autoconf automake autopoint \
   bison build-essential \
   ca-certificates clang clang-format clang-tidy clang-tools cmake curl \
   doxygen-latex dia \
   flex \
   gawk gettext git git-lfs git-remote-hg git-svn global graphviz \
   libarchive-tools libc++-dev libc++abi-dev libclang-dev libtool lld llvm lsb-release \
   mercurial mercurial-git mscgen \
   nasm ninja-build nodejs npm \
   python-jinja2 python-pygments python-simplejson python-six python-yaml \
   python3-jinja2 python3-pygments python3-simplejson python3-six python3-yaml \
   subversion \
   unzip \
   wget \
 && apt-get clean \
 && mkdir /usr/local/lib/x86_64-linux-gnu \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN echo "====== UPDATE NPM ======" \
 && npm -g config set user root \
 && npm -g install npm \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL MOXYGEN ======" \
 && npm -g install moxygen \
 && rm -rf /tmp/* /var/tmp/*

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