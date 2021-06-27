FROM ubuntu:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== CONFIGURE REPOS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  apt-transport-https apt-utils \
  gnupg \
  software-properties-common \
  wget 2>/dev/null \
 && wget -O - https://files.nephatrine.net/Packages/Nephatrine.gpg | apt-key add - 2>/dev/null \
 && wget -O /etc/apt/sources.list.d/NephNET.list https://files.nephatrine.net/Packages/NephDEB-Ubuntu.list \
 && wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | apt-key add - 2>/dev/null \
 && apt-add-repository 'deb https://apt.kitware.com/ubuntu/ focal main' \
 && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" dist-upgrade -y \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  curl \
  file \
  nano \
  rsync \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

ENV LLVM_MAJOR=11

RUN echo "====== INSTALL BUILD TOOLS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  build-essential \
  clang-${LLVM_MAJOR} clang-format-${LLVM_MAJOR} clang-tidy-${LLVM_MAJOR} clang-tools-${LLVM_MAJOR} cmake \
  git git-lfs \
  kitware-archive-keyring \
  lld-${LLVM_MAJOR} lsb-release \
  ninja-build \
  subversion \
 && ls /usr/lib/clang/$LLVM_MAJOR \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL DOXYGEN TOOLS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  dia doxygen-latex \
  global graphviz \
  imagemagick \
  librsvg2-bin \
  mscgen \
  python3-jinja2 python3-pygments \
 && mkdir /opt/m.css \
 && git -C /opt/m.css clone --single-branch --depth=1 https://github.com/mosra/m.css \
 && mv /opt/m.css/m.css/documentation /opt/m.css/bin \
 && mv /opt/m.css/m.css/css /opt/m.css/css \
 && mv /opt/m.css/m.css/plugins /opt/m.css/plugins \
 && mv /opt/m.css/m.css/COPYING /opt/m.css/ \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /tmp/* /var/tmp/* /opt/m.css/m.css /opt/m.css/bin/test*

ENV PATH=/opt/m.css/bin:$PATH
