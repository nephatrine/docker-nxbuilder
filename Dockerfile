FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG SDK_VERSION=10.11
ARG TARGET_DIR=/usr/local
RUN echo "====== DOWNLOAD OSX SDK ======" \
 && mkdir /usr/lib/clang/9.0.0/lib/darwin \
 && cd /usr/src \
 && git clone https://github.com/tpoechtrager/osxcross.git && cd osxcross \
 && wget https://files.nephatrine.net/Local/MacOSX${SDK_VERSION}.sdk.tar.xz -O tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz \
 && yes | ./build.sh && ./build_compiler_rt.sh \
 && cp -nrv ./build/compiler-rt/include/sanitizer /usr/lib/clang/9.0.0/include/ \
 && cp -nv ./build/compiler-rt/build/lib/darwin/*.a /usr/lib/clang/9.0.0/lib/darwin/ \
 && cp -nv ./build/compiler-rt/build/lib/darwin/*.dylib /usr/lib/clang/9.0.0/lib/darwin/ \
 && mv ${TARGET_DIR}/SDK /foreign && mkdir ${TARGET_DIR}/SDK \
 && ln -s /foreign/MacOSX${SDK_VERSION}.sdk ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk \
 && cd /usr/src && rm -rf /usr/src/*

COPY override /
RUN echo "====== TEST BUILD ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/foreign/MacOSX${SDK_VERSION}.sdk/x86_64-toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-x86_64h && cd build-x86_64h \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/foreign/MacOSX${SDK_VERSION}.sdk/x86_64h-toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-i386 && cd build-i386 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/foreign/MacOSX${SDK_VERSION}.sdk/i386-toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*
