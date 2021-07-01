FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV FREEBSD_VERSION=13.0 \
 FREEBSD_SYSROOT_AMD64=/opt/freebsd/sysroot-amd64 FREEBSD_SYSROOT_ARM64=/opt/freebsd/sysroot-arm64 FREEBSD_SYSROOT_RISCV=/opt/freebsd/sysroot-riscv

RUN echo "====== INSTALL FREEBSD ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends libarchive-tools \
 && apt-get autoremove -y && apt-get clean \
 && wget -qO /tmp/freebsd-amd64.txz https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
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
 && wget -qO /tmp/freebsd-arm64.txz https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
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
 && wget -qO /tmp/freebsd-riscv.txz https://download.freebsd.org/ftp/releases/riscv/riscv64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir -p ${FREEBSD_SYSROOT_RISCV} && cd ${FREEBSD_SYSROOT_RISCV} \
 && bsdtar -xf /tmp/freebsd-riscv.txz \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/boot/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/rescue/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/usr/bin/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/usr/libexec/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/usr/sbin/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/usr/share/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/usr/tests/* \
 && rm -rf ${FREEBSD_SYSROOT_RISCV}/var/* \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk -v sysroot=${FREEBSD_SYSROOT_RISCV} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find . -xtype l | xargs ls -l | grep ' /usr/' | awk -v sysroot=${FREEBSD_SYSROOT_RISCV} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && rm -rf /tmp/* /var/tmp/*

COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends llvm-${LLVM_MAJOR}-dev \
 && git -C /usr/src clone --single-branch --depth=1 --branch "release/${LLVM_MAJOR}.x" https://github.com/llvm/llvm-project.git \
 && cp -nrv /usr/src/llvm-project/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && mkdir /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/toolchain.amd64.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-unknown-freebsd${FREEBSD_VERSION}" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/freebsd/*.a ./lib/freebsd/*.so /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/toolchain.arm64.cmake \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="aarch64-unknown-freebsd${FREEBSD_VERSION}" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/freebsd/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && mkdir /tmp/build-riscv && cd /tmp/build-riscv \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/toolchain.riscv.cmake \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="riscv64-unknown-freebsd${FREEBSD_VERSION}" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/freebsd/*.a /usr/lib/clang/${LLVM_MAJOR}/lib/freebsd/ \
 && apt-get remove -y llvm-${LLVM_MAJOR}-dev \
 && apt-get autoremove -y && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/toolchain.amd64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/toolchain.arm64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-riscv && cd /tmp/build-riscv \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/freebsd/toolchain.riscv.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
