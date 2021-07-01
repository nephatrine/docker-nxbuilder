FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DARWIN_SDK=11.3 DARWIN_SDK_I386=0 DARWIN_SDK_ARM64=1 DARWIN_TOOLCHAIN=/opt/osxcross
ENV DARWIN_SYSROOT=${DARWIN_TOOLCHAIN}/SDK/MacOSX${DARWIN_SDK}.sdk
ARG OSX_VERSION_MIN=10.15

RUN echo "====== INSTALL OSXCROSS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libssl-dev libxml2-dev llvm-${LLVM_MAJOR}-dev \
  zlib1g-dev \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/tpoechtrager/osxcross.git \
 && wget -qO /usr/src/osxcross/tarballs/MacOSX${DARWIN_SDK}.sdk.tar.xz https://files.nephatrine.net/Local/MacOSX${DARWIN_SDK}.sdk.tar.xz \
 && export TARGET_DIR=${DARWIN_TOOLCHAIN} \
 && export SDK_VERSION=${DARWIN_SDK} \
 && export SDK_DIR=${DARWIN_SYSROOT} \
 && UNATTENDED=1 /usr/src/osxcross/build.sh \
 && PATH=${TARGET_DIR}/bin:$PATH /usr/src/osxcross/build_compiler_rt.sh \
 && mkdir /usr/lib/clang/${LLVM_MAJOR}/lib/darwin \
 && cp -nv /usr/src/osxcross/build/compiler-rt/compiler-rt/build/lib/darwin/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nv /usr/src/osxcross/build/compiler-rt/compiler-rt/build/lib/darwin/*.dylib /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nrv /usr/src/osxcross/build/compiler-rt/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && apt-get remove -y \
  libssl-dev libxml2-dev llvm-${LLVM_MAJOR}-dev \
  zlib1g-dev \
 && apt-get autoremove -y && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/osxcross

ENV PATH=${DARWIN_TOOLCHAIN}/bin:$PATH

RUN echo "====== CONFIGURE MACPORTS ======" \
 && mkdir -p ${DARWIN_TOOLCHAIN}/macports/pkgs/opt/local \
 && mkdir ${DARWIN_SYSROOT}/opt \
 && ln -s ${DARWIN_TOOLCHAIN}/macports/pkgs/opt/local ${DARWIN_SYSROOT}/opt/local \
 && echo 1 | MACOSX_DEPLOYMENT_TARGET=${DARWIN_SDK} osxcross-macports update-cache

COPY override /

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-x86_64 && cd /tmp/build-x86_64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.x86_64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-x86_64h && cd /tmp/build-x86_64h \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.x86_64h.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && if [ $DARWIN_SDK_I386 -eq 1 ]; then mkdir /tmp/build-i386 && cd /tmp/build-i386 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.i386.cmake /usr/src/hello-test \
 && ninja && file HelloTest; fi \
 && if [ $DARWIN_SDK_ARM64 -eq 1 ]; then mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.arm64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-arm64e && cd /tmp/build-arm64e \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.arm64e.cmake /usr/src/hello-test \
 && ninja && file HelloTest; fi \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
