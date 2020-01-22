FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   libarchive-tools \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG FREEBSD_VERSION=12.1
RUN echo "====== DOWNLOAD FREEBSD ======" \
 && mkdir -p /foreign/FreeBSD-AMD64 && cd /foreign/FreeBSD-AMD64 \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /foreign/FreeBSD-AMD64" $11 " " $9}' | /bin/sh \
 && rm -f base.txz \
 && mkdir /foreign/FreeBSD-ARM64 && cd /foreign/FreeBSD-ARM64 \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /foreign/FreeBSD-ARM64" $11 " " $9}' | /bin/sh \
 && rm -f base.txz \
 && mkdir /foreign/FreeBSD-IA32 && cd /foreign/FreeBSD-IA32 \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /foreign/FreeBSD-IA32" $11 " " $9}' | /bin/sh \
 && rm -f base.txz

COPY override /
RUN echo "====== BUILD COMPILER-RT ======" \
 && mkdir /usr/lib/clang/9.0.0/lib/freebsd \
 && cd /usr/src \
 && git clone --single-branch --branch release_90 https://git.llvm.org/git/compiler-rt.git \
 && mkdir compiler-rt/build && cd compiler-rt/build \
 && cp -nrv ../include/sanitizer /usr/lib/clang/9.0.0/include/ \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/foreign/FreeBSD-AMD64/toolchain.cmake -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/9.0.0/lib/freebsd/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/foreign/FreeBSD-ARM64/toolchain.cmake -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a /usr/lib/clang/9.0.0/lib/freebsd/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/foreign/FreeBSD-IA32/toolchain.cmake -DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/9.0.0/lib/freebsd/ \
 && cd /usr/src && rm -rf /usr/src/*

RUN echo "====== TEST BUILD ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/foreign/FreeBSD-AMD64/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/foreign/FreeBSD-ARM64/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-i386 && cd build-i386 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/foreign/FreeBSD-IA32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*
