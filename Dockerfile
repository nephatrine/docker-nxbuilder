FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   bison flex gawk mtools nasm \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN echo "====== BUILD HAIKU ======" \
 && mkdir /usr/local/lib/x86_64-linux-gnu && cd /usr/src \
 && git clone https://review.haiku-os.org/buildtools.git \
 && cd buildtools/jam \
 && make && ./jam0 install \
 && cd /usr/src \
 && git clone https://review.haiku-os.org/haiku.git && cd haiku \
 && git fetch && git fetch --tags \
 && mkdir /opt/haiku && cd /opt/haiku \
 && /usr/src/haiku/configure --build-cross-tools x86_64 /usr/src/buildtools --use-gcc-pipe -j4 \
 && HAIKU_INSTALL_DIR=/opt/haiku/sysroot-x86_64/boot jam -q @install \
 && cp -nrv /opt/haiku/objects/linux/lib/*.so /usr/local/lib/x86_64-linux-gnu/ && ldconfig \
 && cp -nv /opt/haiku/objects/linux/x86_64/release/tools/package/package /usr/local/bin/ \
 && cp -nrv /opt/haiku/objects/haiku/x86_64/packaging/packages_build/regular/hpkg_-haiku.hpkg/contents/* /opt/haiku/sysroot-x86_64/boot/system/ \
 && cp -nrv /opt/haiku/objects/haiku/x86_64/packaging/packages_build/regular/hpkg_-haiku_devel.hpkg/contents/* /opt/haiku/sysroot-x86_64/boot/system/ \
 && cp -nrv /opt/haiku/objects/haiku/x86_64/packaging/packages_build/regular/hpkg_-haiku_source.hpkg/contents/* /opt/haiku/sysroot-x86_64/boot/system/ \
 && export HAIKU_BASEURL=$(grep baseurl /opt/haiku/objects/haiku/x86_64/packaging/repositories/HaikuPorts-config | tr '=' ' ' | awk '{print $2"/packages"}') \
 && rm -rf Jamfile attributes build build_packages download objects tmp \
 && cd /opt/haiku/sysroot-x86_64/boot/system/packages \
 && grep -Eo 'gcc-.+$|gcc_syslib.+$' /usr/src/haiku/build/jam/repositories/HaikuPorts/x86_64 | xargs -n1 -I{} wget "${HAIKU_BASEURL}/{}-x86_64.hpkg" \
 && find . -type f | xargs -n1 package extract -C .. \
 && find ../develop -xtype l | xargs ls -l | grep ' /system/' | awk '{print "ln -sf /opt/haiku/sysroot-x86_64/boot" $11 " " $9}' | /bin/sh \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/add-ons/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/apps/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/bin/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/demos/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/documentation/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/packages/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/preferences/* \
 && rm -rf /opt/haiku/sysroot-x86_64/boot/system/servers/* \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*
ENV PATH=/opt/haiku/cross-tools-x86_64/bin:$PATH

COPY override /
RUN echo "====== TEST TOOLCHAINS ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/haiku/cross-tools-x86_64/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello \
 && cd /usr/src && rm -rf /usr/src/*