FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV HAIKU_SYSROOT_AMD64=/opt/sysroot-haiku-amd64 HAIKU_TOOLCHAIN_AMD64=/opt/cross-tools/haiku-amd64 \
 HAIKU_SYSROOT_IA32=/opt/sysroot-haiku-ia32 HAIKU_TOOLCHAIN_IA32=/opt/cross-tools/haiku-ia32

RUN echo "====== INSTALL CROSS-GCC ======" \
 && mkdir -p /opt/cross-tools \
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
 && cd /usr/src/buildtools/jam \
 && make && ./jam0 -sBINDIR=/usr/local/bin install \
 && export HAIKU_INSTALL_DIR=${HAIKU_SYSROOT_AMD64}/boot && mkdir -p ${HAIKU_INSTALL_DIR}/system \
 && export TOOLCHAIN_PREFIX=${HAIKU_TOOLCHAIN_AMD64} \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && /usr/src/haiku/configure --distro-compatibility compatible --build-cross-tools x86_64 /usr/src/buildtools --use-gcc-pipe -j4 \
 && jam -q @install \
 && jam -q haiku.hpkg haiku_devel.hpkg haiku_source.hpkg '<build>package' \
 && mkdir /usr/local/lib/x86_64-linux-gnu/ \
 && cp -nrv ./objects/linux/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv ./objects/linux/x86_64/release/tools/package/package /usr/local/bin/ \
 && find ./objects/haiku/x86_64/packaging/packages/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_INSTALL_DIR}/system \
 && find ./download/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_INSTALL_DIR}/system \
 && mv cross-tools-x86_64 ${TOOLCHAIN_PREFIX} \
 && find ${HAIKU_INSTALL_DIR}/ -xtype l | xargs ls -l | grep ' /system/' | awk -v sysroot=${HAIKU_INSTALL_DIR} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find ${HAIKU_INSTALL_DIR}/ -xtype l | xargs ls -l | grep ' /boot/' | awk -v sysroot=${HAIKU_SYSROOT_AMD64} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/add-ons/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/apps/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/bin/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/boot/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/cache/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/data/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/demos/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/develop/documentation/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/documentation/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/packages/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/preferences/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/servers/* \
 && mkdir ${HAIKU_INSTALL_DIR}/system/cache/tmp ${HAIKU_INSTALL_DIR}/system/package-links \
 && ln -s ${HAIKU_INSTALL_DIR} ${HAIKU_SYSROOT_AMD64}/Haiku \
 && ln -s ${HAIKU_INSTALL_DIR}/system ${HAIKU_SYSROOT_AMD64}/system \
 && ln -s ${HAIKU_INSTALL_DIR}/system/bin ${HAIKU_SYSROOT_AMD64}/bin \
 && ln -s ${HAIKU_INSTALL_DIR}/system/cache/tmp ${HAIKU_SYSROOT_AMD64}/tmp \
 && ln -s ${HAIKU_INSTALL_DIR}/system/package-links ${HAIKU_SYSROOT_AMD64}/packages \
 && ln -s ${HAIKU_INSTALL_DIR}/system/settings/etc ${HAIKU_SYSROOT_AMD64}/etc \
 && ln -s ${HAIKU_INSTALL_DIR}/system/var ${HAIKU_SYSROOT_AMD64}/var \
 && export HAIKU_INSTALL_DIR=${HAIKU_SYSROOT_IA32}/boot && mkdir -p ${HAIKU_INSTALL_DIR}/system \
 && export TOOLCHAIN_PREFIX=${HAIKU_TOOLCHAIN_IA32} \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && /usr/src/haiku/configure --distro-compatibility compatible --build-cross-tools x86_gcc2 /usr/src/buildtools --build-cross-tools x86 --use-gcc-pipe -j4 \
 && jam -q @install \
 && jam -q haiku.hpkg haiku_devel.hpkg haiku_source.hpkg '<build>package' \
 && jam -q haiku_x86.hpkg haiku_x86_devel.hpkg \
 && find objects/haiku/x86_gcc2/packaging/packages/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_INSTALL_DIR}/system \
 && find download/ -name '*.hpkg' -type f | xargs -n1 package extract -C ${HAIKU_INSTALL_DIR}/system \
 && mv cross-tools-x86 ${TOOLCHAIN_PREFIX} \
 && find ${HAIKU_INSTALL_DIR}/ -xtype l | xargs ls -l | grep ' /system/' | awk -v sysroot=${HAIKU_INSTALL_DIR} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find ${HAIKU_INSTALL_DIR}/ -xtype l | xargs ls -l | grep ' /boot/' | awk -v sysroot=${HAIKU_SYSROOT_IA32} '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/add-ons/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/apps/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/bin/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/boot/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/cache/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/data/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/demos/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/develop/documentation/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/documentation/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/packages/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/preferences/* \
 && rm -rf ${HAIKU_INSTALL_DIR}/system/servers/* \
 && mkdir ${HAIKU_INSTALL_DIR}/system/cache/tmp ${HAIKU_INSTALL_DIR}/system/package-links \
 && ln -s ${HAIKU_INSTALL_DIR} ${HAIKU_SYSROOT_IA32}/Haiku \
 && ln -s ${HAIKU_INSTALL_DIR}/system ${HAIKU_SYSROOT_IA32}/system \
 && ln -s ${HAIKU_INSTALL_DIR}/system/bin ${HAIKU_SYSROOT_IA32}/bin \
 && ln -s ${HAIKU_INSTALL_DIR}/system/cache/tmp ${HAIKU_SYSROOT_IA32}/tmp \
 && ln -s ${HAIKU_INSTALL_DIR}/system/package-links ${HAIKU_SYSROOT_IA32}/packages \
 && ln -s ${HAIKU_INSTALL_DIR}/system/settings/etc ${HAIKU_SYSROOT_IA32}/etc \
 && ln -s ${HAIKU_INSTALL_DIR}/system/var ${HAIKU_SYSROOT_IA32}/var \
 && apt-get remove -y \
  autoconf automake \
  bison \
  flex \
  gawk gcc-multilib \
  nasm \
  zlib1g-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/buildtools /usr/src/haiku
ENV PATH=${HAIKU_TOOLCHAIN_AMD64}/bin:${HAIKU_TOOLCHAIN_IA32}/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild-amd64 && cd /tmp/nxbuild-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/haiku-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/haiku-amd64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/nxbuild-ia32 && cd /tmp/nxbuild-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/haiku-ia32.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/haiku-ia32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*