FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL GCC-CROSS ======" \
 && dpkg --add-architecture i386 && dpkg --add-architecture x32 \
 && dpkg --add-architecture arm64 && dpkg --add-architecture armhf \
 && dpkg --add-architecture ppc64el && dpkg --add-architecture s390x \
 && sed 's~deb http://archive.ubuntu.com/ubuntu~deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ubuntu-ports~g' /etc/apt/sources.list | grep ports.ubuntu.com >/etc/apt/sources.list.d/ubuntu-ports.list \
 && sed 's~deb http://security.ubuntu.com/ubuntu~deb [arch=arm64,armhf,ppc64el,riscv64,s390x] http://ports.ubuntu.com/ubuntu-ports~g' /etc/apt/sources.list | grep ports.ubuntu.com >>/etc/apt/sources.list.d/ubuntu-ports.list \
 && sed -i 's~deb http://archive.ubuntu.com/ubuntu~deb [arch=amd64,i386,x32] http://archive.ubuntu.com/ubuntu~g' /etc/apt/sources.list \
 && sed -i 's~deb http://security.ubuntu.com/ubuntu~deb [arch=amd64,i386,x32] http://security.ubuntu.com/ubuntu~g' /etc/apt/sources.list \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  binutils-riscv64-linux-gnu binutils-x86-64-linux-gnux32 \
  crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-i386 crossbuild-essential-ppc64el crossbuild-essential-s390x \
  dpkg-dev dpkg-sig \
  g++-riscv64-linux-gnu g++-x86-64-linux-gnux32 gcc-riscv64-linux-gnu gcc-x86-64-linux-gnux32 \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && mkdir /tmp/build-amd64-libc++ && cd /tmp/build-amd64-libc++ \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64-libc++.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-ia32.cmake /usr/src/hello-test \
 && ninja && ninja test \
 && mkdir /tmp/build-amd64-x32 && cd /tmp/build-amd64-x32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64-x32.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-arm64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-armv7 && cd /tmp/build-armv7 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-armv7.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-power64 && cd /tmp/build-power64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-power64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-riscv64 && cd /tmp/build-riscv64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-riscv64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-zarch && cd /tmp/build-zarch \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-zarch.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
