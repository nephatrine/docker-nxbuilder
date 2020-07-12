FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV HAIKU_INSTALL_DIR=/opt/sysroot-haiku TOOLCHAIN_PREFIX=/opt/cross-tools/haiku
ENV PATH=${TOOLCHAIN_PREFIX}/bin:$PATH
COPY override /

RUN echo "====== INSTALL HAIKU ======" \
 && cd /usr/src \
 && git clone https://review.haiku-os.org/buildtools.git \
 && cd buildtools/jam \
 && make && ./jam0 install \
 && cd /usr/src \
 && git clone https://review.haiku-os.org/haiku.git && cd haiku \
 && git fetch && git fetch --tags \
 && cd /opt/cross-tools \
 && /usr/src/haiku/configure --distro-compatibility compatible --build-cross-tools x86_64 /usr/src/buildtools --use-gcc-pipe -j4 \
 && jam -q @install \
 && cp -nrv ./objects/linux/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv ./objects/linux/x86_64/release/tools/package/package /usr/local/bin/ \
 && cp -nrv ./objects/haiku/x86_64/packaging/packages_build/regular/hpkg_-haiku.hpkg/contents/* $HAIKU_INSTALL_DIR/system/ \
 && cp -nrv ./objects/haiku/x86_64/packaging/packages_build/regular/hpkg_-haiku_devel.hpkg/contents/* $HAIKU_INSTALL_DIR/system/ \
 && cp -nrv ./objects/haiku/x86_64/packaging/packages_build/regular/hpkg_-haiku_source.hpkg/contents/* $HAIKU_INSTALL_DIR/system/ \
 && cp -nrv haiku/* cross-tools-x86_64/ && rm -rf haiku && mv cross-tools-x86_64 haiku \
 && export HAIKU_BASEURL=$(grep baseurl ./objects/haiku/x86_64/packaging/repositories/HaikuPorts-config | tr '=' ' ' | awk '{print $2"/packages"}') \
 && rm -rf Jamfile build build_packages download objects tmp \
 && cd $HAIKU_INSTALL_DIR/system/packages \
 && grep -Eo 'gcc-.+$|gcc_syslib.+$' /usr/src/haiku/build/jam/repositories/HaikuPorts/x86_64 | xargs -n1 -I{} wget "${HAIKU_BASEURL}/{}-x86_64.hpkg" \
 && find . -type f | xargs -n1 package extract -C .. \
 && find ../develop -xtype l | xargs ls -l | grep ' /system/' | awk '{print "ln -sf /opt/sysroot-haiku" $11 " " $9}' | /bin/sh \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/* \
 && rm -rf /opt/cross-tools/attributes \
 && rm -rf $HAIKU_INSTALL_DIR/home/config/cache/* \
 && rm -rf $HAIKU_INSTALL_DIR/home/config/non-packaged/add-ons/* \
 && rm -rf $HAIKU_INSTALL_DIR/home/config/non-packaged/bin/* \
 && rm -rf $HAIKU_INSTALL_DIR/home/config/non-packaged/data/* \
 && rm -rf $HAIKU_INSTALL_DIR/home/config/packages/* \
 && rm -rf $HAIKU_INSTALL_DIR/home/config/var/* \
 && rm -rf $HAIKU_INSTALL_DIR/home/mail/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/add-ons/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/apps/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/bin/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/boot/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/cache/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/data/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/demos/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/develop/tools/bin/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/documentation/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/non-packaged/add-ons/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/non-packaged/bin/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/non-packaged/data/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/packages/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/preferences/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/servers/* \
 && rm -rf $HAIKU_INSTALL_DIR/system/var/* \
 && echo "${HAIKU_BASEURL}" >$HAIKU_INSTALL_DIR/home/base-url

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/haiku/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*