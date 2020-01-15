FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   libarchive-tools \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG FREEBSD_VERSION=12.1
RUN echo "====== DOWNLOAD FREEBSD ======" \
 && mkdir /x86_64-freebsd && cd /x86_64-freebsd \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /x86_64-freebsd" $11 " " $9}' | /bin/sh \
 && rm -f base.txz \
 && mkdir /aarch64-freebsd && cd /x86_64-freebsd \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /aarch64-freebsd" $11 " " $9}' | /bin/sh \
 && rm -f base.txz \
 && mkdir /i386-freebsd && cd /x86_64-freebsd \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /i386-freebsd" $11 " " $9}' | /bin/sh \
 && rm -f base.txz

COPY override /
RUN echo "====== UPDATE TOOLCHAINS ======" \
 && cd /x86_64-freebsd \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /x86_64-freebsd/toolchain.cmake \
 && cd /aarch64-freebsd \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /x86_64-freebsd/toolchain.cmake \
 && cd /i386-freebsd \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /x86_64-freebsd/toolchain.cmake
