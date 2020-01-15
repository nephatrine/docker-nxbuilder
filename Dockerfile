FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   libarchive-tools \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY override /

ARG FREEBSD_VERSION=12.1
RUN echo "====== DOWNLOAD FREEBSD ======" \
 && cd /x86_64-freebsd \
 && wget https://download.freebsd.org/ftp/releases/amd64/amd64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /x86_64-freebsd" $11 " " $9}' | /bin/sh \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /x86_64-freebsd/toolchain.cmake \
 && rm -f base.txz \
 && cd /aarch64-freebsd \
 && wget https://download.freebsd.org/ftp/releases/arm64/aarch64/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /aarch64-freebsd" $11 " " $9}' | /bin/sh \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /x86_64-freebsd/toolchain.cmake \
 && rm -f base.txz \
 && cd /i386-freebsd \
 && wget https://download.freebsd.org/ftp/releases/i386/i386/${FREEBSD_VERSION}-RELEASE/base.txz \
 && bsdtar -xf base.txz ./lib/ ./usr/lib/ ./usr/include/ \
 && find . -xtype l | xargs ls -l | grep ' /lib/' | awk '{print "ln -sf /i386-freebsd" $11 " " $9}' | /bin/sh \
 && sed -i "s~freebsdVERSION~freebsd${FREEBSD_VERSION}~g" /x86_64-freebsd/toolchain.cmake \
 && rm -f base.txz
