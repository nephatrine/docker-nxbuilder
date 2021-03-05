FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL GCC-CROSS ======" \
 && dpkg --add-architecture i386 && dpkg --add-architecture arm64 && dpkg --add-architecture armhf \
 && sed 's~deb http://archive.ubuntu.com/ubuntu~deb [arch=arm64,armhf,riscv64] http://ports.ubuntu.com/ubuntu-ports~g' /etc/apt/sources.list | grep ports.ubuntu.com >/etc/apt/sources.list.d/ubuntu-ports.list \
 && sed 's~deb http://security.ubuntu.com/ubuntu~deb [arch=arm64,armhf,riscv64] http://ports.ubuntu.com/ubuntu-ports~g' /etc/apt/sources.list | grep ports.ubuntu.com >>/etc/apt/sources.list.d/ubuntu-ports.list \
 && sed -i 's~deb http://archive.ubuntu.com/ubuntu~deb [arch=amd64,i386] http://archive.ubuntu.com/ubuntu~g' /etc/apt/sources.list \
 && sed -i 's~deb http://security.ubuntu.com/ubuntu~deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu~g' /etc/apt/sources.list \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  binutils-riscv64-linux-gnu \
  crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-i386 \
  dpkg-dev dpkg-sig \
  g++-riscv64-linux-gnu gcc-riscv64-linux-gnu \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

COPY override /

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.amd64.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && mkdir /tmp/build-i386 && cd /tmp/build-i386 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.i386.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.arm64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-armhf && cd /tmp/build-armhf \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.armhf.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-riscv64 && cd /tmp/build-riscv64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/usr/src/toolchain.riscv64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
