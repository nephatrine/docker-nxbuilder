FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV TOOLCHAIN_ARCHS="i686 x86_64 aarch64" TOOLCHAIN_PREFIX=/opt/cross-tools/windows WINEARCH=win64 WINEDLLOVERRIDES="mscoree,mshtml=" WINEPREFIX=/opt/wineprefix
ENV PATH=$TOOLCHAIN_PREFIX/bin:$PATH
COPY override /

RUN echo "====== INSTALL PACKAGES ======" \
 && mkdir /run/uuidd \
 && dpkg --add-architecture i386 \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install libc6:i386 wine-development \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   mingw-w64 mingw-w64-tools \
   nsis \
   osslsigncode \
   wine-binfmt wixl \
   xvfb \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== CONFIGURE WINE ======" \
 && xvfb-run wine64 wineboot --init \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL LLVM-MINGW ======" \
 && cd /usr/src \
 && git clone https://github.com/mstorsjo/llvm-mingw.git && cd llvm-mingw \
 && patch -u wrappers/clang-target-wrapper.sh /usr/src/clang-target-wrapper.patch \
 && mkdir -p $TOOLCHAIN_PREFIX/bin && cp -nrs /usr/lib/llvm-${LLVM_MAJOR}/bin/* $TOOLCHAIN_PREFIX/bin/ \
 && CHECKOUT_ONLY=1 LLVM_VERSION=release/$LLVM_MAJOR.x ./build-llvm.sh $TOOLCHAIN_PREFIX \
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
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== COPY GCC RUNTIMES ======" \
 && mkdir ${WINEPREFIX}/drive_c/i686-w64-mingw32/bin/gcc ${WINEPREFIX}/drive_c/x86_64-w64-mingw32/bin/gcc \
 && cp -nv /usr/lib/gcc/x86_64-w64-mingw32/*-win32/*.dll ${WINEPREFIX}/drive_c/x86_64-w64-mingw32/bin/gcc/ \
 && cp -nv /usr/lib/gcc/i686-w64-mingw32/*-win32/*.dll ${WINEPREFIX}/drive_c/i686-w64-mingw32/bin/gcc/

RUN echo "====== INSTALL MAKEMSIX ======" \
 && cd /usr/src \
 && git clone https://github.com/microsoft/msix-packaging.git && cd msix-packaging \
 && git fetch origin johnmcpms/signing:signing && git checkout signing \
 && ./makelinux.sh --pack --validation-parser \
 && cp -nv .vs/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv .vs/bin/makemsix /usr/local/bin/ \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && sed 's/\\bin/\\@CPACK_NSIS_PACKAGE_PATH@/g' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && sed -i '6 i\ \ !define MUI_BGCOLOR "@CPACK_PACKAGE_COLOR_EXTRA_NH@"' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && sed -i '6 i\ \ !define MUI_TEXTCOLOR "@CPACK_PACKAGE_COLOR_FORE_NH@"' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc/x86_64-w64-mingw32/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64_llvm && cd build-x86_64_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows/toolchain-x86_64.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/usr/lib/gcc/i686-w64-mingw32/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-i686_llvm && cd build-i686_llvm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows/toolchain-i686.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows/toolchain-aarch64.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*