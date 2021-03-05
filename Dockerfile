FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DARWIN_SDK_OLD=10.11 DARWIN_SDK_NEW=10.15 DARWIN_TOOLCHAIN=/opt/osxcross
ENV DARWIN_SYSROOT_OLD=${DARWIN_TOOLCHAIN}/SDK/MacOSX${DARWIN_SDK_OLD}.sdk DARWIN_SYSROOT_NEW=${DARWIN_TOOLCHAIN}/SDK/MacOSX${DARWIN_SDK_NEW}.sdk

RUN echo "====== INSTALL OSXCROSS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libclang-dev libssl-dev libxml2-dev llvm-dev \
  uuid-dev \
  zlib1g-dev \
 && git -C /usr/src clone --depth=1 https://github.com/tpoechtrager/osxcross.git \
 && wget -qO /usr/src/osxcross/tarballs/MacOSX${DARWIN_SDK_OLD}.sdk.tar.xz https://files.nephatrine.net/Local/MacOSX${DARWIN_SDK_OLD}.sdk.tar.xz \
 && wget -qO /usr/src/osxcross/tarballs/MacOSX${DARWIN_SDK_NEW}.sdk.tar.xz https://files.nephatrine.net/Local/MacOSX${DARWIN_SDK_NEW}.sdk.tar.xz \
 && export TARGET_DIR=${DARWIN_TOOLCHAIN} \
 && export SDK_VERSION=${DARWIN_SDK_OLD} \
 && export SDK_DIR=${DARWIN_SYSROOT_OLD} \
 && OSX_VERSION_MIN=${DARWIN_SDK_OLD} UNATTENDED=1 /usr/src/osxcross/build.sh \
 && export SDK_VERSION=${DARWIN_SDK_NEW} \
 && export SDK_DIR=${DARWIN_SYSROOT_NEW} \
 && OSX_VERSION_MIN=${DARWIN_SDK_OLD} UNATTENDED=1 /usr/src/osxcross/build.sh \
 && export PATH=${TARGET_DIR}/bin:$PATH \
 && /usr/src/osxcross/build_compiler_rt.sh \
 && mkdir /usr/lib/clang/${LLVM_MAJOR}/lib/darwin \
 && cp -nv /usr/src/osxcross/build/compiler-rt/compiler-rt/build/lib/darwin/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nv /usr/src/osxcross/build/compiler-rt/compiler-rt/build/lib/darwin/*.dylib /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nrv /usr/src/osxcross/build/compiler-rt/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && apt-get remove -y \
  libclang-dev libssl-dev libxml2-dev llvm-dev \
  uuid-dev \
  zlib1g-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/osxcross

ENV PATH=${DARWIN_TOOLCHAIN}/bin:$PATH

RUN echo "====== CONFIGURE MACPORTS ======" \
 && mkdir -p ${DARWIN_TOOLCHAIN}/macports/pkgs/opt/local \
 && mkdir ${DARWIN_SYSROOT_OLD}/opt && mkdir ${DARWIN_SYSROOT_NEW}/opt \
 && ln -s ${DARWIN_TOOLCHAIN}/macports/pkgs/opt/local ${DARWIN_SYSROOT_OLD}/opt/local \
 && ln -s ${DARWIN_TOOLCHAIN}/macports/pkgs/opt/local ${DARWIN_SYSROOT_NEW}/opt/local \
 && echo 1 | MACOSX_DEPLOYMENT_TARGET=${DARWIN_SDK_OLD} osxcross-macports update-cache

COPY override /

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-x86_64 && cd /tmp/build-x86_64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.x86_64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-x86_64h && cd /tmp/build-x86_64h \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.x86_64h.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-i386 && cd /tmp/build-i386 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DARWIN_TOOLCHAIN}/toolchain.i386.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
