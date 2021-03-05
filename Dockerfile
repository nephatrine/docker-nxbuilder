FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV HAIKU_TOOLCHAIN_AMD64=/opt/haiku/cross-tools-x86_64 \
 HAIKU_TOOLCHAIN_GCC2=/opt/haiku/cross-tools-x86_gcc2 \
 HAIKU_TOOLCHAIN_IA32=/opt/haiku/cross-tools-x86

ENV HAIKU_SYSROOT_AMD64=${HAIKU_TOOLCHAIN_AMD64}/sysroot \
 HAIKU_SYSROOT_GCC2=${HAIKU_TOOLCHAIN_GCC2}/sysroot \
 HAIKU_SYSROOT_IA32=${HAIKU_TOOLCHAIN_IA32}/sysroot

RUN echo "====== INSTALL CROSS-GCC ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  autoconf automake \
  bison \
  flex \
  gawk gcc-multilib \
  nasm \
  zlib1g-dev \
 && git -C /usr/src clone --depth=1 https://review.haiku-os.org/buildtools.git \
 && git -C /usr/src clone --depth=1 https://review.haiku-os.org/haiku.git \
 && cd /usr/src/buildtools/jam && make && ./jam0 -sBINDIR=/usr/local/bin install \
 && mkdir /opt/haiku && cd /opt/haiku \
 && /usr/src/haiku/configure --build-cross-tools x86_64 --cross-tools-source /usr/src/buildtools --distro-compatibility compatible --use-gcc-pipe -j4 \
 && jam -q @install \
 && jam -q haiku.hpkg haiku_devel.hpkg haiku_source.hpkg '<build>package' \
 && mkdir /usr/local/lib/x86_64-linux-gnu/ \
 && cp -nrv ./objects/linux/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv ./objects/linux/x86_64/release/tools/package/package /usr/local/bin/ \
 && mkdir -p ${HAIKU_SYSROOT_AMD64}/boot/system \
 && find ./objects/haiku/x86_64/packaging/packages/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_SYSROOT_AMD64}/boot/system \
 && find ./download/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_SYSROOT_AMD64}/boot/system \
 && find ${HAIKU_SYSROOT_AMD64}/ -xtype l | xargs ls -l | grep ' /system/' | awk -v sysroot=${HAIKU_SYSROOT_AMD64}/boot/ '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find ${HAIKU_SYSROOT_AMD64}/ -xtype l | xargs ls -l | grep ' /boot/' | awk -v sysroot=${HAIKU_SYSROOT_AMD64}/ '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/add-ons/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/apps/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/bin/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/boot/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/cache/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/data/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/demos/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/develop/documentation/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/documentation/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/packages/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/preferences/* \
 && rm -rf ${HAIKU_SYSROOT_AMD64}/boot/system/servers/* \
 && rm -rf Jamfile attributes build build_packages download objects tmp \
 && /usr/src/haiku/configure --build-cross-tools x86_gcc2 --build-cross-tools x86 --cross-tools-source /usr/src/buildtools --distro-compatibility compatible --use-gcc-pipe -j4 \
 && jam -q @install \
 && jam -q haiku.hpkg haiku_devel.hpkg haiku_source.hpkg '<build>package' \
 && jam -q haiku_x86.hpkg haiku_x86_devel.hpkg \
 && mkdir -p ${HAIKU_SYSROOT_GCC2}/boot/system \
 && find ./objects/haiku/x86_gcc2/packaging/packages/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_SYSROOT_GCC2}/boot/system \
 && find ./download/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_SYSROOT_GCC2}/boot/system \
 && find ${HAIKU_SYSROOT_GCC2}/ -xtype l | xargs ls -l | grep ' /system/' | awk -v sysroot=${HAIKU_SYSROOT_GCC2}/boot/ '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find ${HAIKU_SYSROOT_GCC2}/ -xtype l | xargs ls -l | grep ' /boot/' | awk -v sysroot=${HAIKU_SYSROOT_GCC2}/ '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/add-ons/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/apps/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/bin/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/boot/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/cache/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/data/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/demos/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/develop/documentation/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/documentation/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/packages/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/preferences/* \
 && rm -rf ${HAIKU_SYSROOT_GCC2}/boot/system/servers/* \
 && rm -rf Jamfile attributes build build_packages download objects tmp \
 && ln -s ${HAIKU_SYSROOT_GCC2} ${HAIKU_SYSROOT_IA32} \
 && apt-get remove -y \
  autoconf automake \
  bison \
  flex \
  gawk gcc-multilib \
  nasm \
  zlib1g-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/*

ENV PATH=${HAIKU_TOOLCHAIN_AMD64}/bin:${HAIKU_TOOLCHAIN_IA32}/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-x86_64 && cd /tmp/build-x86_64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/haiku/toolchain.x86_64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-x86 && cd /tmp/build-x86 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/haiku/toolchain.x86.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
