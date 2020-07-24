FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL CROSS-BUILD TOOLS ======" \
 && dpkg --add-architecture arm64 \
 && dpkg --add-architecture i386 \
 && dpkg --add-architecture ppc64el \
 && dpkg --add-architecture riscv64 \
 && dpkg --add-architecture s390x \
 && dpkg --add-architecture x32 \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q || true \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
   binutils-riscv64-linux-gnu binutils-x86-64-linux-gnux32 \
   crossbuild-essential-arm64 crossbuild-essential-i386 crossbuild-essential-ppc64el crossbuild-essential-s390x \
   dpkg-dev dpkg-sig \
   g++-riscv64-linux-gnu g++-x86-64-linux-gnux32 gcc-riscv64-linux-gnu gcc-x86-64-linux-gnux32 \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64.cmake /usr/src/hello \
 && ninja && ninja test \
 && mkdir /tmp/build-amd64-libc++ && cd /tmp/build-amd64-libc++ \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64-libc++.cmake /usr/src/hello \
 && ninja && ninja test \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-ia32.cmake /usr/src/hello \
 && ninja && ninja test \
 && mkdir /tmp/build-amd64-x32 && cd /tmp/build-amd64-x32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-amd64-x32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-arm64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-power64 && cd /tmp/build-power64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-power64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-riscv64 && cd /tmp/build-riscv64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-riscv64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-zarch && cd /tmp/build-zarch \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/linux-zarch.cmake /usr/src/hello \
 && ninja && file hello-test \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/*