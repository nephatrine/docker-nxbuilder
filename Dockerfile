FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && dpkg --add-architecture i386 \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   automake autopoint gettext libtool vim yasm \
   cabextract gcab unzip \
   mingw-w64 mingw-w64-tools \
   msitools nsis wixl \
   osslsigncode pesign \
   winbind xvfb \
   wine-development wine-binfmt winetricks \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY clang-target-wrapper.patch /usr/src/clang-target-wrapper.patch
ARG TOOLCHAIN_PREFIX=/llvm-mingw
RUN echo "====== COMPILE LLVM-MINGW ======" \
 && cd /usr/src \
 && git clone https://github.com/mstorsjo/llvm-mingw.git && cd llvm-mingw \
 && git checkout llvm-9.0 \
 && patch -u wrappers/clang-target-wrapper.sh /usr/src/clang-target-wrapper.patch \
 && mkdir -p $TOOLCHAIN_PREFIX/bin && cp -nrs /usr/lib/llvm-9/bin/* $TOOLCHAIN_PREFIX/bin/ \
 && CHECKOUT_ONLY=1 ./build-llvm.sh $TOOLCHAIN_PREFIX \
 && ./install-wrappers.sh $TOOLCHAIN_PREFIX \
 && ./build-mingw-w64.sh $TOOLCHAIN_PREFIX --with-default-msvcrt=ucrt \
 && ./build-compiler-rt.sh $TOOLCHAIN_PREFIX \
 && cp -nrs $TOOLCHAIN_PREFIX/lib/clang/* /usr/lib/llvm-9/lib/clang/ \
 && ./build-mingw-w64-libraries.sh $TOOLCHAIN_PREFIX \
 && ./build-libcxx.sh $TOOLCHAIN_PREFIX \
 && ./build-compiler-rt.sh $TOOLCHAIN_PREFIX --build-sanitizers \
 && cp -nrs $TOOLCHAIN_PREFIX/lib/clang/* /usr/lib/llvm-9/lib/clang/ \
 && ./build-libssp.sh $TOOLCHAIN_PREFIX \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

RUN echo "====== COMPILE MSIX-PACKAGING ======" \
 && cd /usr/src \
 && git clone https://github.com/microsoft/msix-packaging.git && cd msix-packaging \
 && ./makelinux.sh --pack \
 && cp .vs/bin/makemsix /usr/local/bin/ \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

COPY override /
