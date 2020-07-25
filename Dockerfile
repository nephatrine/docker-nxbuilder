FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV FREEBSD_DEPLOYMENT_TARGET=12.1 \
 FREEBSD_SYSROOT_AMD64=/opt/sysroot-freebsd-amd64 FREEBSD_SYSROOT_ARM64=/opt/sysroot-freebsd-arm64 FREEBSD_SYSROOT_IA32=/opt/sysroot-freebsd-ia32

RUN echo "====== INSTALL FREEBSD ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libarchive-tools \
 && apt-get clean \
 && wget -qO /tmp/freebsd-amd64.txz https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_DEPLOYMENT_TARGET}-RELEASE/base.txz \
 && wget -qO /tmp/freebsd-arm64.txz https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_DEPLOYMENT_TARGET}-RELEASE/base.txz \
 && wget -qO /tmp/freebsd-ia32.txz https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_DEPLOYMENT_TARGET}-RELEASE/base.txz \
 && mkdir -p ${FREEBSD_SYSROOT_AMD64} && cd ${FREEBSD_SYSROOT_AMD64} \
 && bsdtar -xf /tmp/freebsd-amd64.txz \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/boot/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/rescue/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/usr/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/usr/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/usr/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/usr/share/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/usr/tests/* \
 && rm -rf ${FREEBSD_SYSROOT_AMD64}/var/* \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk -v sysroot=${FREEBSD_SYSROOT_AMD64} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find . -xtype l | xargs ls -l | grep ' /usr/' | awk -v sysroot=${FREEBSD_SYSROOT_AMD64} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && mkdir -p ${FREEBSD_SYSROOT_ARM64} && cd ${FREEBSD_SYSROOT_ARM64} \
 && bsdtar -xf /tmp/freebsd-arm64.txz \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/boot/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/rescue/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/usr/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/usr/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/usr/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/usr/share/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/usr/tests/* \
 && rm -rf ${FREEBSD_SYSROOT_ARM64}/var/* \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk -v sysroot=${FREEBSD_SYSROOT_ARM64} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find . -xtype l | xargs ls -l | grep ' /usr/' | awk -v sysroot=${FREEBSD_SYSROOT_ARM64} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && mkdir -p ${FREEBSD_SYSROOT_IA32} && cd ${FREEBSD_SYSROOT_IA32} \
 && bsdtar -xf /tmp/freebsd-ia32.txz \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/boot/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/rescue/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/usr/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/usr/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/usr/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/usr/share/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/usr/tests/* \
 && rm -rf ${FREEBSD_SYSROOT_IA32}/var/* \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk -v sysroot=${FREEBSD_SYSROOT_IA32} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find . -xtype l | xargs ls -l | grep ' /usr/' | awk -v sysroot=${FREEBSD_SYSROOT_IA32} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && rm -rf /tmp/* /var/tmp/*
COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libclang-dev llvm-dev \
 && git -C /usr/src clone --depth=1 --branch "release/${LLVM_MAJOR}.x" https://github.com/llvm/llvm-project.git \
 && cp -nrv /usr/src/llvm-project/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && mkdir /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-amd64.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-unknown-freebsd${FREEBSD_DEPLOYMENT_TARGET}" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-arm64.cmake \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="aarch64-unknown-freebsd${FREEBSD_DEPLOYMENT_TARGET}" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/freebsd/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-ia32.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="i386-unknown-freebsd${FREEBSD_DEPLOYMENT_TARGET}" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && apt-get remove -y \
  libclang-dev llvm-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/llvm-project

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-amd64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-arm64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/freebsd-ia32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*

ENV OI_SYSROOT=/opt/sysroot-solaris OI_TOOLCHAIN=/opt/cross-tools/solaris OI_DEPLOYMENT_TARGET=5.11
RUN echo "====== INSTALL OPENINDIANA ======" \
 && wget -qO /tmp/OpenIndiana.tgz https://files.nephatrine.net/Local/OpenIndiana-${OI_DEPLOYMENT_TARGET}-20200719.tgz \
 && mkdir -p ${OI_SYSROOT} && cd ${OI_SYSROOT} \
 && tar -xf /tmp/OpenIndiana.tgz \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== BUILD CROSS-GCC ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  texinfo \
 && export BINUTILS_VERSION=2.34 && export GCC_VERSION=9.3.0 \
 && export GMP_VERSION=6.2.0 && export ISL_VERSION=0.22.1 \
 && export MPC_VERSION=1.1.0 && export MPFR_VERSION=4.0.2 \
 && wget -qO /tmp/binutils-${BINUTILS_VERSION}.tar.xz http://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VERSION}.tar.xz \
 && wget -qO /tmp/gcc-${GCC_VERSION}.tar.xz http://ftpmirror.gnu.org/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz \
 && wget -qO /tmp/gmp-${GMP_VERSION}.tar.xz http://ftpmirror.gnu.org/gmp/gmp-${GMP_VERSION}.tar.xz \
 && wget -qO /tmp/isl-${ISL_VERSION}.tar.xz http://isl.gforge.inria.fr/isl-${ISL_VERSION}.tar.xz \
 && wget -qO /tmp/mpc-${MPC_VERSION}.tar.gz http://ftpmirror.gnu.org/mpc/mpc-${MPC_VERSION}.tar.gz \
 && wget -qO /tmp/mpfr-${MPFR_VERSION}.tar.xz http://ftpmirror.gnu.org/mpfr/mpfr-${MPFR_VERSION}.tar.xz \
 && git -C /usr/src clone --depth=1 https://github.com/OpenIndiana/oi-userland \
 && cd /usr/src \
 && tar -xf /tmp/binutils-${BINUTILS_VERSION}.tar.xz && cd /usr/src/binutils-${BINUTILS_VERSION} \
 && for p in $(ls -v /usr/src/oi-userland/components/developer/binutils/patches/); do patch -p1 -b -V numbered </usr/src/oi-userland/components/developer/binutils/patches/$p; done \
 && cd /usr/src \
 && tar -xf /tmp/gcc-${GCC_VERSION}.tar.xz && cd /usr/src/gcc-${GCC_VERSION} \
 && tar -xf /tmp/gmp-${GMP_VERSION}.tar.xz && mv gmp-${GMP_VERSION} gmp \
 && tar -xf /tmp/isl-${ISL_VERSION}.tar.xz && mv isl-${ISL_VERSION} isl \
 && tar -xf /tmp/mpc-${MPC_VERSION}.tar.gz && mv mpc-${MPC_VERSION} mpc \
 && tar -xf /tmp/mpfr-${MPFR_VERSION}.tar.xz && mv mpfr-${MPFR_VERSION} mpfr \
 && for p in $(ls -v /usr/src/oi-userland/components/developer/gcc-9/patches/); do patch -p1 -b -V numbered </usr/src/oi-userland/components/developer/gcc-9/patches/$p; done \
 && mkdir /tmp/build-binutils && cd /tmp/build-binutils \
 && /usr/src/binutils-${BINUTILS_VERSION}/configure --target=i386-pc-solaris2.11 --prefix=${OI_TOOLCHAIN} --with-sysroot=${OI_SYSROOT} \
  --enable-64-bit-bfd --enable-gold=yes --disable-nls --disable-libtool-lock --enable-largefile=yes \
 && make -j4 && make -j4 -s check && make install \
 && mkdir /tmp/build-gcc && cd /tmp/build-gcc \
 && /usr/src/gcc-${GCC_VERSION}/configure --target=i386-pc-solaris2.11 --prefix=${OI_TOOLCHAIN} --with-sysroot=${OI_SYSROOT} \
  --enable-plugins --enable-initfini-array --enable-languages=c,c++,lto --disable-libitm enable_frame_pointer=yes --with-gnu-ld --with-gnu-as \
 && make -j4 all-gcc && make install-gcc && make -j4 && make -j4 -s check-gcc && make install-strip \
 && apt-get remove -y \
  texinfo \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/binutils-${BINUTILS_VERSION} /usr/src/gcc-${GCC_VERSION}
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/openindiana-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/openindiana-amd64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/openindiana-ia32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*