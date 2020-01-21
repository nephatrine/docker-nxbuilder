FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG SDK_VERSION=10.11
ARG TARGET_DIR=/usr/local
ARG TARGET_DIR_SDK=/foreign
RUN echo "====== DOWNLOAD OSX SDK ======" \
 && cd /usr/src \
 && git clone https://github.com/tpoechtrager/osxcross.git && cd osxcross \
 && wget https://files.nephatrine.net/Local/MacOSX${SDK_VERSION}.sdk.tar.xz -O tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz \
 && yes | ./build.sh && ./build_compiler_rt.sh \
 && mkdir -p /usr/lib/llvm-9/lib/clang/9.0.0/include /usr/lib/llvm-9/lib/clang/9.0.0/lib/darwin \
 && cp -nrv /usr/src/osxcross/build/compiler-rt/include/sanitizer /usr/lib/llvm-9/lib/clang/9.0.0/include \
 && cp -v /usr/src/osxcross/build/compiler-rt/build/lib/darwin/*.a /usr/lib/llvm-9/lib/clang/9.0.0/lib/darwin \
 && cp -v /usr/src/osxcross/build/compiler-rt/build/lib/darwin/*.dylib /usr/lib/llvm-9/lib/clang/9.0.0/lib/darwin \
 && cd /usr/src && rm -rf /usr/src/*

ENV OSXCROSS_SDK=/foreign/MacOSX10.11.sdk
ENV OSXCROSS_TARGET_DIR=/usr/local
COPY override /
