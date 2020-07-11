FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

COPY override /

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-i386 crossbuild-essential-s390x \
   dpkg-dev \
   gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc/x86_64-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-clang && cd build-clang \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/clang/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc-cross/aarch64-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-riscv64 && cd build-riscv64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc-cross/riscv64-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-s390x && cd build-s390x \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc-cross/s390x-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc-cross/i686-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-armhf && cd build-armhf \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc-cross/arm-linux-gnueabihf/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /usr/src/*