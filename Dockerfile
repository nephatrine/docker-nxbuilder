FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && dpkg --add-architecture i386 \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   cabextract gcab unzip \
   msitools nsis wixl \
   osslsigncode pesign \
   winbind xvfb \
   wine-development wine-binfmt winetricks \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG TOOLCHAIN_PREFIX=/opt/llvm-mingw
ARG TOOLCHAIN_ARCHS="i686 x86_64 armv7 aarch64"
RUN echo "====== COMPILE LLVM-MINGW ======" \
 && cd /usr/src \
 && git clone https://github.com/mstorsjo/llvm-mingw.git && cd llvm-mingw \
 && ./build-llvm.sh $TOOLCHAIN_PREFIX \
 && ./strip-llvm.sh $TOOLCHAIN_PREFIX \
 && ./install-wrappers.sh $TOOLCHAIN_PREFIX \
 && ./build-mingw-w64.sh $TOOLCHAIN_PREFIX --with-default-msvcrt=ucrt \
 && ./build-compiler-rt.sh $TOOLCHAIN_PREFIX \
 && ./build-mingw-w64-libraries.sh $TOOLCHAIN_PREFIX \
 && ./build-libcxx.sh $TOOLCHAIN_PREFIX \
 && ./build-compiler-rt.sh $TOOLCHAIN_PREFIX --build-sanitizers \
 && ./build-libssp.sh $TOOLCHAIN_PREFIX --build-sanitizers \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

RUN echo "====== COMPILE MSIX-PACKAGING ======" \
 && cd /usr/src \
 && git clone https://github.com/microsoft/msix-packaging.git && cd msix-packaging \
 && ./makelinux.sh --pack \
 && cp .vs/bin/makemsix /usr/local/bin/ \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

ENV PATH=$TOOLCHAIN_PREFIX/bin:$PATH
