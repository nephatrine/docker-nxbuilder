FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   alien debhelper \
   crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-i386 crossbuild-essential-ppc64el crossbuild-essential-s390x \
   gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ENV LLVM_MAJOR=10
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && CC=gcc CXX=g++ cmake -G "Ninja" /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && CC=gcc CXX=g++ cmake -G "Ninja" /opt/nxb/src/hello \
 && ninja && ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-clang && cd build-clang \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/clang/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-clang && cd build-clang \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/clang/toolchain.cmake /opt/nxb/src/hello \
 && ninja && ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/aarch64-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/aarch64-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-powerpc64le && cd build-powerpc64le \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/powerpc64le-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-powerpc64le && cd build-powerpc64le \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/powerpc64le-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-riscv64 && cd build-riscv64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/riscv64-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-riscv64 && cd build-riscv64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/riscv64-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-s390x && cd build-s390x \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/s390x-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-s390x && cd build-s390x \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/s390x-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/i686-linux-gnu/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/i686-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && ./hello \
 && cd /usr/src/nxbuild \
 && mkdir build-armhf && cd build-armhf \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/arm-linux-gnueabihf/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-armhf && cd build-armhf \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/arm-linux-gnueabihf/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*