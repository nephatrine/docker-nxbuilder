FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV HAIKU_SYSROOT_AMD64=/opt/sysroot-haiku-x86_64 HAIKU_TOOLCHAIN_AMD64=/opt/cross-tools/haiku-x86_64 \
 HAIKU_SYSROOT_I386=/opt/sysroot-haiku-x86 HAIKU_TOOLCHAIN_I386=/opt/cross-tools/haiku-x86
ENV PATH=$HAIKU_TOOLCHAIN_AMD64/bin:$HAIKU_TOOLCHAIN_I386/bin:$PATH
COPY override /

RUN echo "====== INSTALL HAIKU ======" \
 && export HAIKU_INSTALL_DIR=${HAIKU_SYSROOT_AMD64} && mkdir -p $HAIKU_INSTALL_DIR/system \
 && export TOOLCHAIN_PREFIX=${HAIKU_TOOLCHAIN_AMD64} \
 && cd /usr/src \
 && git clone --depth=1 https://review.haiku-os.org/buildtools.git \
 && cd buildtools/jam \
 && make && ./jam0 -sBINDIR=/usr/local/bin install \
 && cd /usr/src \
 && git clone --depth=1 https://review.haiku-os.org/haiku.git \
 && mkdir /tmp/build && cd /tmp/build \
 && /usr/src/haiku/configure --distro-compatibility compatible --build-cross-tools x86_64 /usr/src/buildtools --use-gcc-pipe -j4 \
 && jam -q @install \
 && jam -q haiku.hpkg haiku_devel.hpkg haiku_source.hpkg '<build>package' \
 && cp -nrv ./objects/linux/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv ./objects/linux/x86_64/release/tools/package/package /usr/local/bin/ \
 && find objects/haiku/x86_64/packaging/packages/ -name '*.hpkg' -type f | xargs -n1 package extract -C $HAIKU_INSTALL_DIR/system \
 && find download/ -name '*.hpkg' -type f | xargs -n1 package extract -C $HAIKU_INSTALL_DIR/system \
 && mv cross-tools-x86_64 $TOOLCHAIN_PREFIX \
 && find $HAIKU_INSTALL_DIR/ -xtype l | xargs ls -l | grep ' /system/' | awk -v sysroot="$HAIKU_INSTALL_DIR" '{print "ln -sf " sysroot $11 " " $9}' | /bin/sh \
 && find $HAIKU_INSTALL_DIR/ -xtype l | xargs ls -l | grep ' /boot/' | awk -v sysroot="$HAIKU_INSTALL_DIR" '{print "ln -sf " sysroot $11 " " $9}' | sed -e 's~/boot/~/~g' | /bin/sh \
 && rm -rf $HAIKU_INSTALL_DIR/system/add-ons/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/apps/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/bin/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/boot/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/cache/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/data/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/demos/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/develop/documentation/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/documentation/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/packages/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/preferences/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/servers/* \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/haiku-x86_64.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*