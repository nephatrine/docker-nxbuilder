FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   libarchive-tools \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY override /

ARG FREEBSD_VERSION=11.3
RUN echo "====== PREPARE FREEBSD 11 ======" \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /opt/nxb/FreeBSD_PREVIOUS.cmake \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/x86_64-freebsd-previous && cd /usr/x86_64-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/x86_64-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~x86_64~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /usr/x86_64-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/aarch64-freebsd-previous && cd /usr/aarch64-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/aarch64-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~aarch64~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /usr/aarch64-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/i386-freebsd-previous && cd /usr/i386-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/i386-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~i386~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /usr/i386-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/powerpc/powerpc64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/powerpc64-freebsd-previous && cd /usr/powerpc64-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/powerpc64-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~powerpc64~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /usr/powerpc64-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz

ARG FREEBSD_VERSION=12.1
RUN echo "====== PREPARE FREEBSD 12 ======" \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /opt/nxb/FreeBSD_CURRENT.cmake \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/x86_64-freebsd-current && cd /usr/x86_64-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/x86_64-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~x86_64~g" /opt/nxb/FreeBSD_CURRENT.cmake > /usr/x86_64-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/aarch64-freebsd-current && cd /usr/aarch64-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/aarch64-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~aarch64~g" /opt/nxb/FreeBSD_CURRENT.cmake > /usr/aarch64-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/i386-freebsd-current && cd /usr/i386-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/i386-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~i386~g" /opt/nxb/FreeBSD_CURRENT.cmake > /usr/i386-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/powerpc/powerpc64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /usr/powerpc64-freebsd-current && cd /usr/powerpc64-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /usr/powerpc64-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~powerpc64~g" /opt/nxb/FreeBSD_CURRENT.cmake > /usr/powerpc64-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz
