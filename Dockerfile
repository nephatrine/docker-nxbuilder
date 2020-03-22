FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV SDK_VERSION=10.11
ARG TARGET_DIR=/opt/darwin/cross-tools-llvm
ARG SDK_DIR=/opt/darwin/sysroot-osx
RUN echo "====== DOWNLOAD OSX SDK ======" \
 && mkdir /usr/lib/clang/9.0.0/lib/darwin && cd /usr/src \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install libxml2-dev zlib1g-dev \
 && git clone https://github.com/tpoechtrager/osxcross.git && cd osxcross \
 && wget https://files.nephatrine.net/Local/MacOSX${SDK_VERSION}.sdk.tar.xz -O tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz \
 && yes | ./build.sh && PATH=${TARGET_DIR}/bin:$PATH ./build_compiler_rt.sh \
 && cp -nrv ./build/compiler-rt/compiler-rt/include/sanitizer /usr/lib/clang/9.0.0/include/ \
 && cp -nv ./build/compiler-rt/compiler-rt/build/lib/darwin/*.a /usr/lib/clang/9.0.0/lib/darwin/ \
 && cp -nv ./build/compiler-rt/compiler-rt/build/lib/darwin/*.dylib /usr/lib/clang/9.0.0/lib/darwin/ \
 && mv ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk ${SDK_DIR} \
 && ln -s ${SDK_DIR} ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk \
 && apt-get -y -q purge libxml2-dev zlib1g-dev \
 && apt-get -y -q autoremove \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/lib/apt/lists/* /var/tmp/*

ENV PATH=${TARGET_DIR}/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TARGET_DIR}/toolchain-x86_64.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-x86_64h && cd build-x86_64h \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TARGET_DIR}/toolchain-x86_64h.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-i386 && cd build-i386 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TARGET_DIR}/toolchain-i386.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && lipo build-i386/hello build-x86_64/hello build-x86_64h/hello -create -output hello \
 && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*