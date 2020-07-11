FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV SDK_DIR=/opt/sysroot-darwin SDK_VERSION=10.11 TARGET_DIR=/opt/cross-tools/darwin
ENV PATH=${TARGET_DIR}/bin:$PATH
COPY override /

RUN echo "====== DOWNLOAD OSX SDK ======" \
 && mkdir /usr/lib/clang/${LLVM_MAJOR}/lib/darwin && cd /usr/src \
 && git clone https://github.com/tpoechtrager/osxcross.git && cd osxcross \
 && wget https://files.nephatrine.net/Local/MacOSX${SDK_VERSION}.sdk.tar.xz -O tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz \
 && yes | ./build.sh && PATH=${TARGET_DIR}/bin:$PATH ./build_compiler_rt.sh \
 && cp -nrv ./build/compiler-rt/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && cp -nv ./build/compiler-rt/compiler-rt/build/lib/darwin/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nv ./build/compiler-rt/compiler-rt/build/lib/darwin/*.dylib /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && mv ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk ${SDK_DIR} \
 && ln -s ${SDK_DIR} ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk \
 && cd /usr/src && rm -rf /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin/toolchain-x86_64.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64h && cd build-x86_64h \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin/toolchain-x86_64h.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-i386 && cd build-i386 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin/toolchain-i386.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /usr/src/*