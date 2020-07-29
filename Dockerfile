FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV WINEARCH=win64 WINEDEBUG=fixme-all WINEPREFIX=/opt/wine-root WINE=/usr/bin/wine64-development WINESERVER=/usr/bin/wineserver-development

RUN echo "====== INSTALL WINE ======" \
 && dpkg --add-architecture i386 \
 && sed -i 's~deb http://archive.ubuntu.com/ubuntu~deb [arch=amd64,i386] http://archive.ubuntu.com/ubuntu~g' /etc/apt/sources.list \
 && sed -i 's~deb http://security.ubuntu.com/ubuntu~deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu~g' /etc/apt/sources.list \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  wine32-development wine64-development winetricks \
 && export WINEDLLOVERRIDES="mscoree,mshtml=" \
 && DISPLAY= ${WINE} wineboot --init \
 && while pgrep ${WINESERVER} >/dev/null; do sleep 5; done \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL MINGW ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  mingw-w64 mingw-w64-tools \
  nsis \
  osslsigncode \
  wixl \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*
ENV WINDOWS_SYSROOT=${WINEPREFIX}/drive_c WINDOWS_TOOLCHAIN=/opt/cross-tools/windows
COPY override /

RUN echo "====== BUILD LLVM-MINGW ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libclang-dev llvm-dev \
  python3-distutils \
 && export TOOLCHAIN_PREFIX=${WINDOWS_TOOLCHAIN} && export TOOLCHAIN_ARCHS="i686 x86_64 aarch64" \
 && git -C /usr/src clone --depth=1 https://github.com/mstorsjo/llvm-mingw.git && cd /usr/src/llvm-mingw \
 && patch -u ./wrappers/clang-target-wrapper.sh /usr/src/clang-target-wrapper.patch \
 && CHECKOUT_ONLY=1 LLVM_VERSION=release/${LLVM_MAJOR}.x ./build-llvm.sh ${TOOLCHAIN_PREFIX} \
 && ./install-wrappers.sh ${TOOLCHAIN_PREFIX} && export PATH=${TOOLCHAIN_PREFIX}/bin:$PATH \
 && cp -nrvs /usr/lib/llvm-${LLVM_MAJOR}/bin/* ${TOOLCHAIN_PREFIX}/bin/ \
 && ./build-mingw-w64.sh ${TOOLCHAIN_PREFIX} --with-default-msvcrt=ucrt \
 && ./build-compiler-rt.sh ${TOOLCHAIN_PREFIX} \
 && cp -nrvs ${TOOLCHAIN_PREFIX}/lib/clang/* /usr/lib/llvm-${LLVM_MAJOR}/lib/clang/ \
 && ./build-mingw-w64-libraries.sh ${TOOLCHAIN_PREFIX} \
 && ./build-libcxx.sh ${TOOLCHAIN_PREFIX} \
 && ./build-compiler-rt.sh ${TOOLCHAIN_PREFIX} --build-sanitizers \
 && cp -nrvs ${TOOLCHAIN_PREFIX}/lib/clang/* /usr/lib/llvm-${LLVM_MAJOR}/lib/clang/ \
 && ./build-libssp.sh ${TOOLCHAIN_PREFIX} \
 && apt-get remove -y \
  libclang-dev llvm-dev \
  python3-distutils \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/llvm-mingw /usr/src/clang-target-wrapper.patch

RUN echo "====== BUILD MAKEMSIX ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libicu-dev \
 && git -C /usr/src clone --depth=1 --branch "johnmcpms/signing" https://github.com/microsoft/msix-packaging.git \
 && cd /usr/src/msix-packaging && ./makelinux.sh --pack --validation-parser \
 && mkdir /usr/local/lib/x86_64-linux-gnu && cp -nv .vs/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv .vs/bin/makemsix /usr/local/bin/ \
 && apt-get remove -y \
  libicu-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && sed -i 's/\\bin/\\@CPACK_NSIS_PACKAGE_PATH@/g' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && sed -i '6 i\ \ !define MUI_BGCOLOR "@CPACK_PACKAGE_COLOR_EXTRA_NH@"' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && sed -i '6 i\ \ !define MUI_TEXTCOLOR "@CPACK_PACKAGE_COLOR_FORE_NH@"' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/mingw-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32/libgcc && ln -s /usr/lib/gcc/x86_64-w64-mingw32/*-win32 ${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32/libgcc \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/mingw-amd64.cmake /usr/src/hello \
 && ninja && ${WINE} ./hello-test.exe \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/i686-w64-mingw32/libgcc && ln -s /usr/lib/gcc/i686-w64-mingw32/*-win32 ${WINDOWS_TOOLCHAIN}/i686-w64-mingw32/libgcc \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/mingw-ia32.cmake /usr/src/hello \
 && ninja && ${WINE} ./hello-test.exe \
 && export PATH=${TOOLCHAIN_PREFIX}/bin:$PATH \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32/bin && ln -s ${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32 ${WINDOWS_SYSROOT}/x86_64-w64-mingw32 \
 && mkdir /tmp/build-amd64-libc++ && cd /tmp/build-amd64-libc++ \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/mingw-amd64-libc++.cmake /usr/src/hello \
 && ninja && ${WINE} ./hello-test.exe \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/aarch64-w64-mingw32/bin && ln -s ${WINDOWS_TOOLCHAIN}/aarch64-w64-mingw32 ${WINDOWS_SYSROOT}/aarch64-w64-mingw32 \
 && mkdir /tmp/build-arm64-libc++ && cd /tmp/build-arm64-libc++ \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/mingw-arm64-libc++.cmake /usr/src/hello \
 && ninja && file hello-test.exe \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/i686-w64-mingw32/bin && ln -s ${WINDOWS_TOOLCHAIN}/i686-w64-mingw32 ${WINDOWS_SYSROOT}/i686-w64-mingw32 \
 && mkdir /tmp/build-ia32-libc++ && cd /tmp/build-ia32-libc++ \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/mingw-ia32-libc++.cmake /usr/src/hello \
 && ninja && ${WINE} ./hello-test.exe \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*