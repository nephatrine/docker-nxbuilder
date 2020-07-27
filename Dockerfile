FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DJGPP_TOOLCHAIN=/opt/cross-tools/djgpp

RUN echo "====== INSTALL GCC-CROSS ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  autoconf automake-1.15 \
  bison \
  flex \
  groff \
  texinfo \
  unzip \
  zlib1g-dev \
 && update-alternatives --set automake /usr/bin/automake-1.15 \
 && export DJGPP_PREFIX=${DJGPP_TOOLCHAIN} && export DJDIR=${DJGPP_TOOLCHAIN}/i586-pc-msdosdjgpp \
 && git -C /usr/src clone --depth=1 https://github.com/jwt27/djgpp-cvs.git && cd /usr/src/djgpp-cvs/src \
 && sed -i 's/Werror/Wno-error/g' makefile.cfg \
 && make misc.exe makemake.exe \
 && make ../hostbin \
 && make -C djasm native \
 && make -C stub native \
 && mkdir -p ${DJGPP_TOOLCHAIN}/bin ${DJDIR} \
 && cp -nrv ../include ${DJDIR}/sys-include \
 && cp -npv ../hostbin/stubify.exe ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-stubify && ln -s i586-pc-msdosdjgpp-stubify ${DJGPP_TOOLCHAIN}/bin/stubify \
 && cp -npv ../hostbin/stubedit.exe ${DJGPP_TOOLCHAIN}/bin/i586-pc-msdosdjgpp-stubedit && ln -s i586-pc-msdosdjgpp-stubedit ${DJGPP_TOOLCHAIN}/bin/stubedit \
 && export BINTUILS_MAJOR=2 && export BINTUILS_MINOR=34 \
 && export GCC_MAJOR=9 && export GCC_MINOR=3 \
 && export GMP_VERSION=6.2.0 && export ISL_VERSION=0.22.1 \
 && export MPC_VERSION=1.1.0 && export MPFR_VERSION=4.0.2 \
 && wget -qO /tmp/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip http://delorie.com/pub/djgpp/current/v2gnu/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip \
 && wget -qO /tmp/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2 http://delorie.com/pub/djgpp/rpms/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2 \
 && wget -qO /tmp/gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz http://ftpmirror.gnu.org/gcc/gcc-${GCC_MAJOR}.${GCC_MINOR}.0/gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz \
 && wget -qO /tmp/gmp-${GMP_VERSION}.tar.xz http://ftpmirror.gnu.org/gmp/gmp-${GMP_VERSION}.tar.xz \
 && wget -qO /tmp/isl-${ISL_VERSION}.tar.xz http://isl.gforge.inria.fr/isl-${ISL_VERSION}.tar.xz \
 && wget -qO /tmp/mpc-${MPC_VERSION}.tar.gz http://ftpmirror.gnu.org/mpc/mpc-${MPC_VERSION}.tar.gz \
 && wget -qO /tmp/mpfr-${MPFR_VERSION}.tar.xz http://ftpmirror.gnu.org/mpfr/mpfr-${MPFR_VERSION}.tar.xz \
 && cd /usr/src \
 && tar -xf /tmp/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2 && cd djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0 \
 && mv /tmp/gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz ./ && sh unpack-gcc.sh --no-djgpp-source gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz \
 && tar -xf /tmp/gmp-${GMP_VERSION}.tar.xz && mv gmp-${GMP_VERSION} ./gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/gmp \
 && tar -xf /tmp/isl-${ISL_VERSION}.tar.xz && mv isl-${ISL_VERSION} ./gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/isl \
 && tar -xf /tmp/mpc-${MPC_VERSION}.tar.gz && mv mpc-${MPC_VERSION} ./gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/mpc \
 && tar -xf /tmp/mpfr-${MPFR_VERSION}.tar.xz && mv mpfr-${MPFR_VERSION} ./gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/mpfr \
 && unzip -oq /tmp/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip \
 && chmod +x ./gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}/install-sh \
 && chmod +x ./gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}/missing \
 && chmod +x ./gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}/configure \
 && mkdir /tmp/build-binutils && cd /tmp/build-binutils \
 && /usr/src/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0/gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}/configure \
  --target=i586-pc-msdosdjgpp --prefix=${DJGPP_TOOLCHAIN} --disable-werror --disable-nls \
 && make -j4 configure-bfd && make -j4 -C bfd stmp-lcoff-h \
 && make -j4 && make -j4 -s check && make install \
 && export PATH=${DJGPP_TOOLCHAIN}/bin:$PATH \
 && mkdir /tmp/build-gcc && cd /tmp/build-gcc \
 && /usr/src/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0/gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/configure --disable-plugin --enable-lto --disable-nls --enable-libquadmath-support --enable-version-specific-runtime-libs \
  --enable-fat --enable-libstdcxx-filesystem-ts --target=i586-pc-msdosdjgpp --prefix=${DJGPP_TOOLCHAIN} --enable-languages=c,c++ \
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
  autoconf automake-1.15 \
  bison \
  flex \
  groff \
  texinfo \
  unzip \
  zlib1g-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0 /usr/src/djgpp-cvs
ENV DJDIR=${DJGPP_TOOLCHAIN}/i586-pc-msdosdjgpp PATH=${DJGPP_TOOLCHAIN}/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && mv /usr/share/cmake/Modules/Platform/*.cmake /usr/share/cmake-*/Modules/Platform/ \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/djgpp-ia32.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/djgpp-ia32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*