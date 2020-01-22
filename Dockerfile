FROM ubuntu:rolling
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -qq install apt-utils \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   build-essential cmake gdb global ninja-build valgrind \
   ca-certificates curl wget \
   clang clang-format clang-tidy clang-tools libc++-dev libc++abi-dev libclang-dev lld lldb llvm \
   doxygen-latex dia graphviz mscgen \
   git git-lfs git-remote-hg git-svn mercurial mercurial-git subversion \
   liblzma-dev libomp-dev libxml2-dev zlib1g-dev \
   lsb-release sudo \
   nodejs npm \
   python-jinja2 python-pygments python-simplejson python-six python-yaml \
   python3-jinja2 python3-pygments python3-simplejson python3-six python3-yaml \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN echo "====== CONFIGURE USER ======" \
 && adduser \
   --home /home/guardian \
   --shell /bin/bash \
   --uid 1000 \
   --ingroup users \
   --disabled-password \
   --gecos "docker end-user" \
   guardian

RUN echo "====== INSTALL M.CSS ======" \
 && mkdir /opt/m.css && cd /opt/m.css \
 && git clone https://github.com/mosra/m.css && cd m.css \
 && mv documentation ../bin \
 && mv css ../css \
 && mv plugins ../plugins \
 && mv COPYING ../ \
 && cd .. && rm -rf m.css bin/test*
ENV PATH=/opt/m.css/bin:$PATH

RUN echo "====== UPDATE NPM ======" \
 && npm -g config set user root \
 && npm -g install npm \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL MOXYGEN ======" \
 && npm -g install moxygen \
 && rm -rf /tmp/* /var/tmp/*

COPY override /
