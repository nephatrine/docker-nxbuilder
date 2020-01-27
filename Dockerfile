FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && dpkg --add-architecture i386 \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   winbind wine-development winetricks xvfb \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   automake autopoint gettext libtool vim yasm \
   cabextract gcab unzip \
   mingw-w64 mingw-w64-tools \
   msitools nsis wixl \
   osslsigncode pesign \
   wine-binfmt \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ENV WINEARCH=win64 WINEPREFIX=/foreign/Wine64
ARG WINEDLLOVERRIDES="mscoree,mshtml="
RUN echo "====== CONFIGURE WINE ======" \
 && mkdir /foreign \
 && xvfb-run wine64 wineboot --init \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== COMPILE MSIX-PACKAGING ======" \
 && cd /usr/src \
 && git clone https://github.com/microsoft/msix-packaging.git && cd msix-packaging \
 && ./makelinux.sh --pack \
 && mkdir /usr/local/lib/x86_64-linux-gnu \
 && cp -nv .vs/lib/*.so /usr/local/lib/x86_64-linux-gnu/ \
 && cp -nv .vs/bin/makemsix /usr/local/bin/ \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

COPY clang-target-wrapper.patch /usr/src/clang-target-wrapper.patch
ARG TOOLCHAIN_PREFIX=/opt/llvm-mingw
ARG LLVM_VERSION=release/9.x
RUN echo "====== COMPILE LLVM-MINGW ======" \
 && cd /usr/src \
 && git clone https://github.com/mstorsjo/llvm-mingw.git && cd llvm-mingw \
# && git checkout llvm-9.0
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
 && rm -rf /opt/llvm-mingw/bin/*gcc /opt/llvm-mingw/bin/*g++ \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

COPY override /
RUN echo "====== TEST BUILD ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/x86_64-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=/usr/lib/gcc/x86_64-w64-mingw32/9.2-win32 wine ./hello.exe \
 && cd /usr/src \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/i686-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=/usr/lib/gcc/i686-w64-mingw32/9.2-win32 wine ./hello.exe \
 && cd /usr/src \
 && mkdir build-x86_64_llvm && cd build-x86_64_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/llvm-mingw/x86_64-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=/opt/llvm-mingw/x86_64-w64-mingw32/bin wine ./hello.exe \
 && cd /usr/src \
 && mkdir build-i686_llvm && cd build-i686_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/llvm-mingw/i686-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=/opt/llvm-mingw/i686-w64-mingw32/bin wine ./hello.exe \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/llvm-mingw/aarch64-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello.exe \
 && cd /usr/src \
 && mkdir build-armv7 && cd build-armv7 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/llvm-mingw/armv7-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello.exe \
 && cd /usr/src && rm -rf /usr/src/*
