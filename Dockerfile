FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV FREEBSD_VERSION=12.1
RUN echo "====== DOWNLOAD FREEBSD ======" \
 && mkdir -p /opt/freebsd/sysroot-x86_64 && cd /opt/freebsd/sysroot-x86_64 \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /opt/freebsd/sysroot-x86_64" $11 " " $9}' | /bin/sh \
 && rm -f base.txz \
 && mkdir /opt/freebsd/sysroot-aarch64 && cd /opt/freebsd/sysroot-aarch64 \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /opt/freebsd/sysroot-aarch64" $11 " " $9}' | /bin/sh \
 && rm -f base.txz

COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && mkdir /usr/lib/clang/9.0.0/lib/freebsd \
 && cd /usr/src \
 && git clone --single-branch --branch release_90 https://git.llvm.org/git/compiler-rt.git \
 && mkdir compiler-rt/build && cd compiler-rt/build \
 && cp -nrv ../include/sanitizer /usr/lib/clang/9.0.0/include/ \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/cross-tools-x86_64/toolchain.cmake .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/9.0.0/lib/freebsd/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/cross-tools-aarch64/toolchain.cmake -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a /usr/lib/clang/9.0.0/lib/freebsd/ \
 && cd /usr/src && rm -rf /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/cross-tools-x86_64/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/cross-tools-aarch64/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*