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
  less \
  nano \
  rsync \
 && apt-get autoremove -y && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

ENV LLVM_MAJOR=11

RUN echo "====== INSTALL BUILD TOOLS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  autoconf automake \
  build-essential \
  clang-${LLVM_MAJOR} clang-format-${LLVM_MAJOR} clang-tidy-${LLVM_MAJOR} clang-tools-${LLVM_MAJOR} cmake \
  git git-lfs \
  kitware-archive-keyring \
  libc++1-${LLVM_MAJOR} libc++abi1-${LLVM_MAJOR} lld-${LLVM_MAJOR} llvm-${LLVM_MAJOR} lsb-release \
  ninja-build \
  subversion \
 && update-alternatives --install /usr/bin/llvm-config llvm-config /usr/bin/llvm-config-${LLVM_MAJOR} 100 \
  --slave /usr/bin/llvm-addr2line llvm-addr2line /usr/bin/llvm-addr2line-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-ar llvm-ar /usr/bin/llvm-ar-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-lib llvm-lib /usr/bin/llvm-lib-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-mt llvm-mt /usr/bin/llvm-mt-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-nm llvm-nm /usr/bin/llvm-nm-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-objcopy llvm-objcopy /usr/bin/llvm-objcopy-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-objdump llvm-objdump /usr/bin/llvm-objdump-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-ranlib llvm-ranlib /usr/bin/llvm-ranlib-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-rc llvm-rc /usr/bin/llvm-rc-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-readelf llvm-readelf /usr/bin/llvm-readelf-${LLVM_MAJOR} \
  --slave /usr/bin/llvm-strip llvm-strip /usr/bin/llvm-strip-${LLVM_MAJOR} \
 && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_MAJOR} 100 \
  --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_MAJOR} \
  --slave /usr/bin/clang-cl clang-cl /usr/bin/clang-cl-${LLVM_MAJOR} \
  --slave /usr/bin/clang-cpp clang-cpp /usr/bin/clang-cpp-${LLVM_MAJOR} \
  --slave /usr/bin/clang-format clang-format /usr/bin/clang-format-${LLVM_MAJOR} \
  --slave /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${LLVM_MAJOR} \
 && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${LLVM_MAJOR} 100 \
  --slave /usr/bin/ld.lld ld.lld /usr/bin/ld.lld-${LLVM_MAJOR} \
  --slave /usr/bin/ld64.lld ld64.lld /usr/bin/ld64.lld-${LLVM_MAJOR} \
  --slave /usr/bin/lld-link lld-link /usr/bin/lld-link-${LLVM_MAJOR} \
  --slave /usr/bin/wasm-ld wasm-ld /usr/bin/wasm-ld-${LLVM_MAJOR} \
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
