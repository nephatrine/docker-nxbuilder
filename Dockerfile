FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DARWIN_SYSROOT=/opt/sysroot-darwin DARWIN_TOOLCHAIN=/opt/cross-tools/darwin MACOSX_DEPLOYMENT_TARGET=10.11
RUN echo "====== DOWNLOAD OSX SDK ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libclang-dev libssl-dev libxml2-dev llvm-dev \
  uuid-dev \
  zlib1g-dev \
 && export SDK_VERSION=$MACOSX_DEPLOYMENT_TARGET \
 && export SDK_DIR=$DARWIN_SYSROOT \
 && export TARGET_DIR=$DARWIN_TOOLCHAIN \
 && git -C /usr/src clone --depth=1 https://github.com/tpoechtrager/osxcross.git \
 && wget -qO /usr/src/osxcross/tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz https://files.nephatrine.net/Local/MacOSX${SDK_VERSION}.sdk.tar.xz \
 && UNATTENDED=1 /usr/src/osxcross/build.sh \
 && export PATH=$TARGET_DIR/bin:$PATH \
 && /usr/src/osxcross/build_compiler_rt.sh \
 && mkdir /usr/lib/clang/$LLVM_MAJOR/lib/darwin \
 && cp -nv /usr/src/osxcross/build/compiler-rt/compiler-rt/build/lib/darwin/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nv /usr/src/osxcross/build/compiler-rt/compiler-rt/build/lib/darwin/*.dylib /usr/lib/clang/${LLVM_MAJOR}/lib/darwin/ \
 && cp -nrv /usr/src/osxcross/build/compiler-rt/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && mv ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk ${SDK_DIR} \
 && ln -s ${SDK_DIR} ${TARGET_DIR}/SDK/MacOSX${SDK_VERSION}.sdk \
 && mkdir -p ${SDK_DIR}/opt/local && mkdir -p ${TARGET_DIR}/macports/pkgs/opt \
 && ln -s ${SDK_DIR}/opt/local ${TARGET_DIR}/macports/pkgs/opt/local \
 && apt-get remove -y \
  libclang-dev libssl-dev libxml2-dev llvm-dev \
  uuid-dev \
  zlib1g-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/osxcross
ENV PATH=$DARWIN_TOOLCHAIN/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin-amd64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-amd64-haswell && cd /tmp/build-amd64-haswell \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin-amd64-haswell.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/darwin-ia32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*