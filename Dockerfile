FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && mkdir /run/uuidd \
 && dpkg --add-architecture i386 \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install libc6:i386 \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install wine-development \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   cabextract gcab \
   mingw-w64 mingw-w64-tools \
   msitools nsis \
   osslsigncode pesign \
   wine-binfmt winetricks \
   wixl xvfb \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ENV WINEARCH=win64 WINEPREFIX=/opt/windows/sysroot-wine
ARG WINEDLLOVERRIDES="mscoree,mshtml="
RUN echo "====== CONFIGURE WINE ======" \
 && mkdir /opt/windows \
 && xvfb-run wine64 wineboot --init \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== BUILD MSIX-PACKAGING ======" \
 && cd /usr/src \
 && git clone https://github.com/microsoft/msix-packaging.git && cd msix-packaging \
 && ./makelinux.sh --pack \
 && cp -nv .vs/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv .vs/bin/makemsix /usr/local/bin/ \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

COPY clang-target-wrapper.patch /usr/src/clang-target-wrapper.patch
ARG TOOLCHAIN_ARCHS="i686 x86_64 aarch64"
ARG TOOLCHAIN_PREFIX=/opt/windows/cross-tools-llvm
ENV LLVM_MAJOR=10
ARG LLVM_VERSION=release/${LLVM_MAJOR}.x
RUN echo "====== BUILD LLVM-MINGW ======" \
 && cd /usr/src \
 && git clone https://github.com/mstorsjo/llvm-mingw.git && cd llvm-mingw \
 && patch -u wrappers/clang-target-wrapper.sh /usr/src/clang-target-wrapper.patch \
 && mkdir -p $TOOLCHAIN_PREFIX/bin && cp -nrs /usr/lib/llvm-${LLVM_MAJOR}/bin/* $TOOLCHAIN_PREFIX/bin/ \
 && CHECKOUT_ONLY=1 ./build-llvm.sh $TOOLCHAIN_PREFIX \
 && ./install-wrappers.sh $TOOLCHAIN_PREFIX \
 && ./build-mingw-w64.sh $TOOLCHAIN_PREFIX --with-default-msvcrt=ucrt \
 && ./build-compiler-rt.sh $TOOLCHAIN_PREFIX \
 && cp -nrs $TOOLCHAIN_PREFIX/lib/clang/* /usr/lib/llvm-${LLVM_MAJOR}/lib/clang/ \
 && ./build-mingw-w64-libraries.sh $TOOLCHAIN_PREFIX \
 && ./build-libcxx.sh $TOOLCHAIN_PREFIX \
 && ./build-compiler-rt.sh $TOOLCHAIN_PREFIX --build-sanitizers \
 && cp -nrs $TOOLCHAIN_PREFIX/lib/clang/* /usr/lib/llvm-${LLVM_MAJOR}/lib/clang/ \
 && ./build-libssp.sh $TOOLCHAIN_PREFIX \
 && cp -nrv $TOOLCHAIN_PREFIX/generic-w64-mingw32 ${WINEPREFIX}/drive_c/ \
 && mv $TOOLCHAIN_PREFIX/x86_64-w64-mingw32 ${WINEPREFIX}/drive_c/ \
 && mv $TOOLCHAIN_PREFIX/i686-w64-mingw32 ${WINEPREFIX}/drive_c/ \
 && mv $TOOLCHAIN_PREFIX/i386-w64-mingw32 ${WINEPREFIX}/drive_c/ \
 && mv $TOOLCHAIN_PREFIX/aarch64-w64-mingw32 ${WINEPREFIX}/drive_c/ \
 && rm -rf $TOOLCHAIN_PREFIX/bin/*-gcc $TOOLCHAIN_PREFIX/bin/*-g++ $TOOLCHAIN_PREFIX/generic-w64-mingw32 \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

RUN echo "====== COPY GCC RUNTIMES ======" \
 && mkdir ${WINEPREFIX}/drive_c/i686-w64-mingw32/bin/gcc ${WINEPREFIX}/drive_c/x86_64-w64-mingw32/bin/gcc \
 && cp -nv /usr/lib/gcc/x86_64-w64-mingw32/*-win32/*.dll ${WINEPREFIX}/drive_c/x86_64-w64-mingw32/bin/gcc/ \
 && cp -nv /usr/lib/gcc/i686-w64-mingw32/*-win32/*.dll ${WINEPREFIX}/drive_c/i686-w64-mingw32/bin/gcc/

ENV PATH=$TOOLCHAIN_PREFIX/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/x86_64-w64-mingw32/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/x86_64-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=${WINEPREFIX}/drive_c/x86_64-w64-mingw32/bin/gcc wine64 ./hello.exe \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64_llvm && cd build-x86_64_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PREFIX}/toolchain-x86_64.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-x86_64_llvm && cd build-x86_64_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PREFIX}/toolchain-x86_64.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=${WINEPREFIX}/drive_c/x86_64-w64-mingw32/bin wine64 ./hello.exe \
 && cd /usr/src/nxbuild \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/i686-w64-mingw32/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/i686-w64-mingw32/toolchain.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=${WINEPREFIX}/drive_c/i686-w64-mingw32/bin/gcc wine ./hello.exe \
 && cd /usr/src/nxbuild \
 && mkdir build-i686_llvm && cd build-i686_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PREFIX}/toolchain-i686.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-i686_llvm && cd build-i686_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PREFIX}/toolchain-i686.cmake /opt/nxb/src/hello \
 && ninja && WINEPATH=${WINEPREFIX}/drive_c/i686-w64-mingw32/bin wine ./hello.exe \
 && cd /usr/src/nxbuild \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PREFIX}/toolchain-aarch64.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_PREFIX}/toolchain-aarch64.cmake /opt/nxb/src/hello \
 && ninja && file ./hello.exe \
 && cd /usr/src && rm -rf /usr/src/*