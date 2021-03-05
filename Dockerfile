FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV WINEARCH=win64 WINEDEBUG=fixme-all WINEPREFIX=/opt/wine-prefix WINE=/usr/bin/wine64-development WINESERVER=/usr/bin/wineserver-development

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
 && sed -i 's/\\bin/\\@CPACK_NSIS_PACKAGE_PATH@/g' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && sed -i '6 i\ \ !define MUI_BGCOLOR "@CPACK_PACKAGE_COLOR_EXTRA_NH@"' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && sed -i '6 i\ \ !define MUI_TEXTCOLOR "@CPACK_PACKAGE_COLOR_FORE_NH@"' /usr/share/cmake-*/Modules/Internal/CPack/NSIS.template.in \
 && rm -rf /tmp/* /var/tmp/*

ENV WINDOWS_SYSROOT=${WINEPREFIX}/drive_c WINDOWS_TOOLCHAIN=/opt/llvm-mingw
COPY patches /

RUN echo "====== BUILD LLVM-MINGW ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  gawk \
  libclang-dev llvm-dev \
  python3-distutils \
 && export TOOLCHAIN_ARCHS="i686 x86_64 aarch64" \
 && git -C /usr/src clone -b llvm-${LLVM_MAJOR}.0 --single-branch --depth=1 https://github.com/mstorsjo/llvm-mingw.git \
 && cd /usr/src/llvm-mingw && patch -u ./wrappers/clang-target-wrapper.sh /usr/src/clang-target-wrapper.patch \
 && CHECKOUT_ONLY=1 LLVM_VERSION=release/${LLVM_MAJOR}.x ./build-llvm.sh ${WINDOWS_TOOLCHAIN} \
 && ./install-wrappers.sh ${WINDOWS_TOOLCHAIN} \
 && export PATH=${WINDOWS_TOOLCHAIN}/bin:$PATH \
 && cp -nrvs /usr/lib/llvm-${LLVM_MAJOR}/bin/* ${WINDOWS_TOOLCHAIN}/bin/ \
 && ./build-mingw-w64.sh ${WINDOWS_TOOLCHAIN} \
 && ./build-compiler-rt.sh ${WINDOWS_TOOLCHAIN} \
 && cp -nrvs ${WINDOWS_TOOLCHAIN}/lib/clang/* /usr/lib/llvm-${LLVM_MAJOR}/lib/clang/ \
 && ./build-mingw-w64-libraries.sh ${WINDOWS_TOOLCHAIN} \
 && ./build-libcxx.sh ${WINDOWS_TOOLCHAIN} \
 && ./build-compiler-rt.sh ${WINDOWS_TOOLCHAIN} --build-sanitizers \
 && cp -nrvs ${WINDOWS_TOOLCHAIN}/lib/clang/* /usr/lib/llvm-${LLVM_MAJOR}/lib/clang/ \
 && sed -i 's~https://github.com/gcc-mirror/gcc/tags/releases/gcc-7.3.0/libssp~svn://gcc.gnu.org/svn/gcc/tags/gcc_7_3_0_release/libssp~g' build-libssp.sh \
 && ./build-libssp.sh ${WINDOWS_TOOLCHAIN} \
 && ln -s /usr/lib/gcc/x86_64-w64-mingw32/*-win32 ${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32/libgcc \
 && ln -s /usr/lib/gcc/i686-w64-mingw32/*-win32 ${WINDOWS_TOOLCHAIN}/i686-w64-mingw32/libgcc \
 && ln -s ${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32 ${WINDOWS_SYSROOT}/x86_64-w64-mingw32 \
 && ln -s ${WINDOWS_TOOLCHAIN}/i686-w64-mingw32 ${WINDOWS_SYSROOT}/i686-w64-mingw32 \
 && ln -s ${WINDOWS_TOOLCHAIN}/aarch64-w64-mingw32 ${WINDOWS_SYSROOT}/aarch64-w64-mingw32 \
 && apt-get remove -y \
  gawk \
  libclang-dev llvm-dev \
  python3-distutils \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/*

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
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/msix-packaging

COPY override /

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32/libgcc \
 && mkdir /tmp/build-x86_64-stdcxx && cd /tmp/build-x86_64-stdcxx \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.x86_64-stdcxx.cmake /usr/src/hello-test \
 && ninja && ${WINE} ./HelloTest.exe \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/i686-w64-mingw32/libgcc \
 && mkdir /tmp/build-i686-stdcxx && cd /tmp/build-i686-stdcxx \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.i686-stdcxx.cmake /usr/src/hello-test \
 && ninja && ${WINE} ./HelloTest.exe \
 && export PATH=${WINDOWS_TOOLCHAIN}/bin:$PATH \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/x86_64-w64-mingw32/bin \
 && mkdir /tmp/build-x86_64-libcxx && cd /tmp/build-x86_64-libcxx \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.x86_64-libcxx.cmake /usr/src/hello-test \
 && ninja && ${WINE} ./HelloTest.exe \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/aarch64-w64-mingw32/bin \
 && mkdir /tmp/build-aarch64-libcxx && cd /tmp/build-aarch64-libcxx \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.aarch64-libcxx.cmake /usr/src/hello-test \
 && ninja && file HelloTest.exe \
 && export WINEPATH=${WINDOWS_TOOLCHAIN}/i686-w64-mingw32/bin \
 && mkdir /tmp/build-i686-libcxx && cd /tmp/build-i686-libcxx \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.i686-libcxx.cmake /usr/src/hello-test \
 && ninja && ${WINE} ./HelloTest.exe \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
