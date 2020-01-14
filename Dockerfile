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
 && mkdir /x86_64-freebsd-previous && cd /x86_64-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /x86_64-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~x86_64~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /x86_64-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /aarch64-freebsd-previous && cd /aarch64-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /aarch64-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~aarch64~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /aarch64-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /i386-freebsd-previous && cd /i386-freebsd-previous \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /i386-freebsd-previous" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~i386~g" /opt/nxb/FreeBSD_PREVIOUS.cmake > /i386-freebsd-previous/toolchain.cmake \
 && rm -f /usr/src/base.txz

ARG FREEBSD_VERSION=12.1
RUN echo "====== PREPARE FREEBSD 12 ======" \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /opt/nxb/FreeBSD_CURRENT.cmake \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /x86_64-freebsd-current && cd /x86_64-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /x86_64-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~x86_64~g" /opt/nxb/FreeBSD_CURRENT.cmake > /x86_64-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /aarch64-freebsd-current && cd /aarch64-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /aarch64-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~aarch64~g" /opt/nxb/FreeBSD_CURRENT.cmake > /aarch64-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz \
 && cd /usr/src \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && mkdir /i386-freebsd-current && cd /i386-freebsd-current \
 && bsdtar -xf /usr/src/base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /i386-freebsd-current" $11 " " $9}' | /bin/sh \
 && sed "s~__ARCHITECTURE__~i386~g" /opt/nxb/FreeBSD_CURRENT.cmake > /i386-freebsd-current/toolchain.cmake \
 && rm -f /usr/src/base.txz
