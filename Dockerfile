FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DJGPP_TOOLCHAIN=/opt/djgpp
ENV DJDIR=${DJGPP_TOOLCHAIN}/i586-pc-msdosdjgpp PATH=${DJGPP_TOOLCHAIN}/bin:$PATH

RUN echo "====== INSTALL GCC-CROSS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  automake-1.15 \
  bison \
  libgmp3-dev libisl-dev libmpc-dev libmpfr-dev \
  texinfo \
  unzip \
  zlib1g-dev \
 && update-alternatives --set automake /usr/bin/automake-1.15 \
 && export DJGPP_PREFIX=${DJGPP_TOOLCHAIN} \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/jwt27/djgpp-cvs.git && cd /usr/src/djgpp-cvs/src \
 && sed -i 's/Werror/Wno-error/g' makefile.cfg \
 && make misc.exe makemake.exe \
 && make ../hostbin \
 && make -C djasm native \
 && make -C stub native \
 && mkdir -p ${DJGPP_TOOLCHAIN}/bin ${DJDIR} \
 && cp -nrv ../lib ${DJDIR}/lib \
 && cp -nrv ../include ${DJDIR}/sys-include \
 && cp -npv ../hostbin/stubify.exe ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-stubify && ln -s i586-pc-msdosdjgpp-stubify ${DJGPP_TOOLCHAIN}/bin/stubify \
 && cp -npv ../hostbin/stubedit.exe ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-stubedit && ln -s i586-pc-msdosdjgpp-stubedit ${DJGPP_TOOLCHAIN}/bin/stubedit \
 && export BINTUILS_DJGPP_VERSION=2351 && export BINTUILS_GNU_VERISON=2.35.1 \
 && export GCC_DJGPP_VERSION=10.20 && export GCC_GNU_VERSION=10.2.0 \
 && wget -qO /tmp/bnu${BINTUILS_DJGPP_VERSION}s.zip http://delorie.com/pub/djgpp/current/v2gnu/bnu${BINTUILS_DJGPP_VERSION}s.zip \
 && wget -qO /tmp/djcross-gcc-${GCC_GNU_VERSION}.tar.bz2 http://delorie.com/pub/djgpp/rpms/djcross-gcc-${GCC_GNU_VERSION}/djcross-gcc-${GCC_GNU_VERSION}.tar.bz2 \
 && wget -qO /tmp/gcc-${GCC_GNU_VERSION}.tar.xz http://ftpmirror.gnu.org/gcc/gcc-${GCC_GNU_VERSION}/gcc-${GCC_GNU_VERSION}.tar.xz \
 && cd /usr/src \
 && tar -xf /tmp/djcross-gcc-${GCC_GNU_VERSION}.tar.bz2 && cd djcross-gcc-${GCC_GNU_VERSION} \
 && mv /tmp/gcc-${GCC_GNU_VERSION}.tar.xz ./ && sh unpack-gcc.sh --no-djgpp-source gcc-${GCC_GNU_VERSION}.tar.xz \
 && unzip -oq /tmp/bnu${BINTUILS_DJGPP_VERSION}s.zip \
 && chmod +x ./gnu/binutils-${BINTUILS_GNU_VERISON}/install-sh \
 && chmod +x ./gnu/binutils-${BINTUILS_GNU_VERISON}/missing \
 && chmod +x ./gnu/binutils-${BINTUILS_GNU_VERISON}/configure \
 && mkdir /tmp/build-binutils && cd /tmp/build-binutils \
 && /usr/src/djcross-gcc-${GCC_GNU_VERSION}/gnu/binutils-${BINTUILS_GNU_VERISON}/configure --target=i586-pc-msdosdjgpp --prefix=${DJGPP_TOOLCHAIN} --disable-werror --disable-nls \
 && make -j4 configure-bfd && make -j4 -C bfd stmp-lcoff-h \
 && make -j4 && make -j4 -s check && make install \
 && export PATH=${DJGPP_TOOLCHAIN}/bin:$PATH \
 && mkdir /tmp/build-gcc && cd /tmp/build-gcc \
 && /usr/src/djcross-gcc-${GCC_GNU_VERSION}/gnu/gcc-${GCC_DJGPP_VERSION}/configure --target=i586-pc-msdosdjgpp --prefix=${DJGPP_TOOLCHAIN} --disable-plugin --enable-lto --disable-nls --enable-libquadmath-support --enable-version-specific-runtime-libs --enable-fat --enable-libstdcxx-filesystem-ts --enable-languages=c,c++ \
 && make -j4 all-gcc && make install-gcc \
 && cd /usr/src/djgpp-cvs/src \
 && make config && make -j4 -C mkdoc && make -j4 -C libc \
 && cp -nrv ../lib/* ${DJDIR}/lib/ \
 && cd /tmp/build-gcc \
 && make -j4 \
 && make -j4 -s check-gcc && make install-strip \
 && cd /usr/src/djgpp-cvs/src \
 && make -j4 -C utils native \
 && make -j4 -C dxe native \
 && make -j4 -C dxe -f makefile.dxe \
 && make -j4 -C debug \
 && make -j4 -C libemu \
 && make -j4 -C libm \
 && make -j4 -C docs \
 && make -j4 -C ../zoneinfo/src \
 && make -j4 -f makempty \
 && mkdir -p ${DJDIR}/share/info && cp -nrv ../info/* ${DJDIR}/share/info/ \
 && cp -nrv ../lib/* ${DJDIR}/lib/ \
 && cp -npv ../hostbin/djasm.exe ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-djasm && ln -s i586-pc-msdosdjgpp-djasm ${DJGPP_TOOLCHAIN}/bin/djasm \
 && cp -npv ../hostbin/dxegen.exe ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-dxe3gen && ln -s i586-pc-msdosdjgpp-dxe3gen ${DJGPP_TOOLCHAIN}/bin/dxe3gen \
 && cp -npv dxe/dxe3res ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-dxe3res && ln -s i586-pc-msdosdjgpp-dxe3res ${DJGPP_TOOLCHAIN}/bin/dxe3res \
 && ln -s i586-pc-msdosdjgpp-dxe3gen ${DJGPP_TOOLCHAIN}/bin/dxegen \
 && apt-get remove -y \
  automake-1.15 \
  bison \
  libgmp3-dev libisl-dev libmpc-dev libmpfr-dev \
  texinfo \
  zlib1g-dev \
 && apt-get autoremove -y && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/*

COPY override /

RUN echo "====== TEST TOOLCHAIN ======" \
 && mv /usr/share/cmake/Modules/Platform/*.cmake /usr/share/cmake-*/Modules/Platform/ \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${DJGPP_TOOLCHAIN}/toolchain.cmake /usr/src/hello-test \
 && ninja && file hello.exe \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
