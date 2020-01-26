FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   alien debhelper \
   crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-ppc64el crossbuild-essential-s390x \
   git-buildpackage git-buildpackage-rpm mercurial-buildpackage svn-buildpackage \
   gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY override /
RUN echo "====== TEST BUILD ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && CC=gcc CXX=g++ cmake -G "Ninja" /opt/nxb/src/hello \
 && ninja && ./hello \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/aarch64-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-powerpc64le && cd build-powerpc64le \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/powerpc64le-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-riscv64 && cd build-riscv64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/riscv64-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-s390x && cd build-s390x \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/s390x-linux-gnu/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-arm && cd build-arm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/arm-linux-gnuabihf/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*
