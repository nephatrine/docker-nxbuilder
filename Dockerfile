FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV FREEBSD_VERSION=12.1
ENV FREEBSD_PREFIX=/opt/freebsd

RUN echo "====== DOWNLOAD FREEBSD x86_64 ======" \
 && mkdir -p "${FREEBSD_PREFIX}/sysroot-x86_64" && cd "${FREEBSD_PREFIX}/sysroot-x86_64" \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /opt/freebsd/sysroot-x86_64" $11 " " $9}' | /bin/sh \
 && rm -f base.txz

RUN echo "====== DOWNLOAD FREEBSD i386 ======" \
 && mkdir -p "${FREEBSD_PREFIX}/sysroot-i386" && cd "${FREEBSD_PREFIX}/sysroot-i386" \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /opt/freebsd/sysroot-i386" $11 " " $9}' | /bin/sh \
 && rm -f base.txz

RUN echo "====== DOWNLOAD FREEBSD aarch64 ======" \
 && mkdir -p "${FREEBSD_PREFIX}/sysroot-aarch64" && cd "${FREEBSD_PREFIX}/sysroot-aarch64" \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /opt/freebsd/sysroot-aarch64" $11 " " $9}' | /bin/sh \
 && rm -f base.txz

ENV SOLARIS_VERSION=5.11
ENV SOLARIS_PREFIX=/opt/solaris
ARG SOLARIS_TRIPLET=i386-pc-solaris2.11

RUN echo "====== DOWNLOAD OPENINDIANA ======" \
 && mkdir -p "${SOLARIS_PREFIX}/sysroot" && cd "${SOLARIS_PREFIX}/sysroot" \
 && wget https://files.nephatrine.net/Local/OpenIndiana-20200330.tgz -O OpenIndiana.tgz \
 && tar -xzf OpenIndiana.tgz && rm -f OpenIndiana.tgz

RUN echo "====== DOWNLOAD OPENINDIANA PATCHES ======" \
 && cd /usr/src \
 && git clone https://github.com/OpenIndiana/oi-userland \
 && mkdir -p "${SOLARIS_PREFIX}/patches/binutils/" \
 && cp oi-userland/components/developer/binutils/patches/*.patch "${SOLARIS_PREFIX}/patches/binutils/" \
 && mkdir -p "${SOLARIS_PREFIX}/patches/gcc/" \
 && cp oi-userland/components/developer/gcc-9/patches/*.patch "${SOLARIS_PREFIX}/patches/gcc/" \
 && rm -rf /usr/src/*

ARG GNU_MIRROR=http://ftpmirror.gnu.org
ARG BINUTILS_VERSION=2.34

RUN echo "====== BUILD BINUTILS ======" \
 && cd /usr/src \
 && curl -f "${GNU_MIRROR}/binutils/binutils-${BINUTILS_VERSION}.tar.xz" -L -o "binutils-${BINUTILS_VERSION}.tar.xz" \
 && tar xJf "binutils-${BINUTILS_VERSION}.tar.xz" && cd "binutils-${BINUTILS_VERSION}" \
 && for p in $(ls -v "${SOLARIS_PREFIX}/patches/binutils/"); do patch -p1 -b -V numbered < "${SOLARIS_PREFIX}/patches/binutils/$p"; done \
 && mkdir ../binutils-build && cd ../binutils-build \
 && ../binutils-${BINUTILS_VERSION}/configure --target=${SOLARIS_TRIPLET} --prefix=${SOLARIS_PREFIX} --with-sysroot=${SOLARIS_PREFIX}/sysroot --enable-64-bit-bfd --enable-gold=no --disable-nls --disable-libtool-lock --enable-largefile=yes \
 && make -j4 && make -j4 -s check && make install \
 && cd /usr/src && rm -rf /usr/src/*

ARG ISL_MIRROR=http://isl.gforge.inria.fr
ARG GCC_VERSION=9.3.0
ARG GMP_VERSION=6.2.0
ARG MPC_VERSION=1.1.0
ARG MPFR_VERSION=4.0.2
ARG ISL_VERSION=0.22.1

# export ac_cv_objext=o

RUN echo "====== BUILD GCC ======" \
 && cd /usr/src \
 && curl -f "${GNU_MIRROR}/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz" -L -o "gcc-${GCC_VERSION}.tar.xz" \
 && tar xJf "gcc-${GCC_VERSION}.tar.xz" && cd "gcc-${GCC_VERSION}" \
 && curl -f "${GNU_MIRROR}/gmp/gmp-${GMP_VERSION}.tar.xz" -L -o "gmp-${GMP_VERSION}.tar.xz" \
 && tar xJf "gmp-${GMP_VERSION}.tar.xz" && mv "gmp-${GMP_VERSION}" gmp \
 && curl -f "${GNU_MIRROR}/mpfr/mpfr-${MPFR_VERSION}.tar.xz" -L -o "mpfr-${MPFR_VERSION}.tar.xz" \
 && tar xJf "mpfr-${MPFR_VERSION}.tar.xz" && mv "mpfr-${MPFR_VERSION}" mpfr \
 && curl -f "${GNU_MIRROR}/mpc/mpc-${MPC_VERSION}.tar.gz" -L -o "mpc-${MPC_VERSION}.tar.gz" \
 && tar xzf "mpc-${MPC_VERSION}.tar.gz" && mv "mpc-${MPC_VERSION}" mpc \
 && curl -f "${ISL_MIRROR}/isl-${ISL_VERSION}.tar.xz" -L -o "isl-${ISL_VERSION}.tar.xz" \
 && tar xJf "isl-${ISL_VERSION}.tar.xz" && mv "isl-${ISL_VERSION}" isl \
 && for p in $(ls -v "${SOLARIS_PREFIX}/patches/gcc/"); do patch -p1 -b -V numbered < "${SOLARIS_PREFIX}/patches/gcc/$p"; done \
 && mkdir ../gcc-build && cd ../gcc-build \
 && ../gcc-${GCC_VERSION}/configure --target=${SOLARIS_TRIPLET} --prefix=${SOLARIS_PREFIX} --with-sysroot=${SOLARIS_PREFIX}/sysroot --enable-plugins --enable-initfini-array --enable-languages=c,c++,lto --disable-libitm enable_frame_pointer=yes --with-gnu-ld --with-gnu-as \
 && make -j4 all-gcc && make install-gcc \
 && make -j4 && make -j4 -s check-gcc && make install-strip

ENV LLVM_MAJOR=10
COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && mkdir /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd && cd /usr/src \
 && git clone --single-branch --branch "release/${LLVM_MAJOR}.x" https://github.com/llvm/llvm-project.git && cd llvm-project/compiler-rt \
 && cp -nrv include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && mkdir build && cd build \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${FREEBSD_PREFIX}/toolchain-x86_64.cmake -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-unknown-freebsd${FREEBSD_VERSION}" .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${FREEBSD_PREFIX}/toolchain-i386.cmake -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="i386-unknown-freebsd${FREEBSD_VERSION}" .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so  /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${FREEBSD_PREFIX}/toolchain-aarch64.cmake -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="aarch64-unknown-freebsd${FREEBSD_VERSION}" .. \
 && ninja \
 && cp -nv ./lib/freebsd/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && cd /usr/src && rm -rf /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && cd /usr/src \
 && mkdir build-x86_64-bsd && cd build-x86_64-bsd \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${FREEBSD_PREFIX}/toolchain-x86_64.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-i386-bsd && cd build-i386-bsd \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${FREEBSD_PREFIX}/toolchain-i386.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-aarch64-bsd && cd build-aarch64-bsd \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${FREEBSD_PREFIX}/toolchain-aarch64.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-x86_64-oi && cd build-x86_64-oi \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${SOLARIS_PREFIX}/toolchain-x86_64.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src \
 && mkdir build-i386-oi && cd build-i386-oi \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${SOLARIS_PREFIX}/toolchain-i386.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*