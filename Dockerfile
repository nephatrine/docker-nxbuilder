FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DJGPP_PREFIX=/opt/djgpp
ARG TRIPLET=i586-pc-msdosdjgpp

ARG DJGPP_MIRROR=http://www.mirrorservice.org/sites/ftp.delorie.com/pub/djgpp
ARG BINTUILS_MAJOR=2
ARG BINTUILS_MINOR=34

RUN echo "====== BUILD BINUTILS ======" \
 && apt-get update -q \
 && apt-get -y -q -o DPkg::Options::="--force-confnew" install texinfo \
 && cd /usr/src \
 && mkdir "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s" && cd "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s" \
 && curl -f "${DJGPP_MIRROR}/current/v2gnu/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" -L -o "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" \
 && unzip -oq "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" \
 && cd "gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}" \
 && chmod +x install-sh && chmod +x missing && chmod +x configure \
 && mkdir build-${TRIPLET} && cd build-${TRIPLET} \
 && ../configure --target=${TRIPLET} --prefix=${DJGPP_PREFIX} --disable-werror --disable-nls \
 && make -j4 configure-bfd && make -j4 -C bfd stmp-lcoff-h \
 && make -j4 && make -j4 -s check && make install \
 && cd /usr/src \
 && apt-get -y -q purge texinfo && apt-get -y -q autoremove \
 && rm -rf /tmp/* /usr/src/* /var/lib/apt/lists/* /var/tmp/*
ENV PATH="$DJGPP_PREFIX/bin:$PATH"

ARG GNU_MIRROR=http://ftpmirror.gnu.org
ARG ISL_MIRROR=http://isl.gforge.inria.fr
ARG GCC_MAJOR=9
ARG GCC_MINOR=2
ARG GMP_VERSION=6.2.0
ARG MPC_VERSION=1.1.0
ARG MPFR_VERSION=4.0.2
ARG ISL_VERSION=0.22.1

RUN echo "====== BUILD GCC ======" \
 && apt-get update -q \
 && apt-get -y -q -o DPkg::Options::="--force-confnew" install automake-1.15 texinfo zlib1g-dev \
 && update-alternatives --set automake /usr/bin/automake-1.15 \
 && cd /usr/src \
 && git clone https://github.com/jwt27/djgpp-cvs.git "/usr/src/djgpp-cvs" && cd "djgpp-cvs/src" \
 && sed -i 's/Werror/Wno-error/g' makefile.cfg \
 && make misc.exe makemake.exe \
 && make ../hostbin \
 && make -C djasm native \
 && make -C stub native \
 && mkdir -p "${DJGPP_PREFIX}/${TRIPLET}/sys-include" \
 && cp -rp ../include/* "${DJGPP_PREFIX}/${TRIPLET}/sys-include/" \
 && mkdir -p "${DJGPP_PREFIX}/bin" \
 && cp -p ../hostbin/stubify.exe "${DJGPP_PREFIX}/bin/${TRIPLET}-stubify" \
 && cp -p ../hostbin/stubedit.exe "${DJGPP_PREFIX}/bin/${TRIPLET}-stubedit" \
 && ln -s "${TRIPLET}-stubify" "${DJGPP_PREFIX}/bin/stubify" \
 && ln -s "${TRIPLET}-stubedit" "${DJGPP_PREFIX}/bin/stubedit" \
 && cd /usr/src \
 && curl -f "${DJGPP_MIRROR}/rpms/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2" -L -o "djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2" \
 && tar xjf "djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2" && cd "djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0" \
 && curl -f "${GNU_MIRROR}/gcc/gcc-${GCC_MAJOR}.${GCC_MINOR}.0/gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz" -L -o "gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz" \
 && sh unpack-gcc.sh --no-djgpp-source "gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz" \
 && curl -f "${GNU_MIRROR}/gmp/gmp-${GMP_VERSION}.tar.xz" -L -o "gmp-${GMP_VERSION}.tar.xz" \
 && tar xJf "gmp-${GMP_VERSION}.tar.xz" && mv "gmp-${GMP_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/gmp" \
 && curl -f "${GNU_MIRROR}/mpfr/mpfr-${MPFR_VERSION}.tar.xz" -L -o "mpfr-${MPFR_VERSION}.tar.xz" \
 && tar xJf "mpfr-${MPFR_VERSION}.tar.xz" && mv "mpfr-${MPFR_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/mpfr" \
 && curl -f "${GNU_MIRROR}/mpc/mpc-${MPC_VERSION}.tar.gz" -L -o "mpc-${MPC_VERSION}.tar.gz" \
 && tar xzf "mpc-${MPC_VERSION}.tar.gz" && mv "mpc-${MPC_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/mpc" \
 && curl -f "${ISL_MIRROR}/isl-${ISL_VERSION}.tar.xz" -L -o "isl-${ISL_VERSION}.tar.xz" \
 && tar xJf "isl-${ISL_VERSION}.tar.xz" && mv "isl-${ISL_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/isl" \
 && mkdir djcross && cd djcross \
 && ../gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/configure --disable-plugin --enable-lto --disable-nls --enable-libquadmath-support --enable-version-specific-runtime-libs --enable-fat --enable-libstdcxx-filesystem-ts --target=${TRIPLET} --prefix=${DJGPP_PREFIX} --enable-languages=c,c++ \
 && make -j4 all-gcc && make install-gcc \
 && cd "/usr/src/djgpp-cvs/src" \
 && make config \
 && make -j4 -C mkdoc \
 && make -j4 -C libc \
 && mkdir -p "${DJGPP_PREFIX}/${TRIPLET}/lib" \
 && cp -rp ../lib/* "${DJGPP_PREFIX}/${TRIPLET}/lib/" \
 && cd "/usr/src/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0" \
 && cd djcross \
 && make -j4 \
 && make -j4 -s check-gcc && make install-strip \
 && cd "/usr/src/djgpp-cvs/src" \
 && make -j4 -C utils native \
 && make -j4 -C dxe native \
 && make -j4 -C dxe -f makefile.dxe \
 && make -j4 -C debug \
 && make -j4 -C libemu \
 && make -j4 -C libm \
 && make -j4 -C docs \
 && make -j4 -C ../zoneinfo/src \
 && make -j4 -f makempty \
 && cp -rp ../lib/* "${DJGPP_PREFIX}/${TRIPLET}/lib/" \
 && mkdir -p "${DJGPP_PREFIX}/${TRIPLET}/share/info" \
 && cp -rp ../info/* "${DJGPP_PREFIX}/${TRIPLET}/share/info/" \
 && cp -p ../hostbin/djasm.exe "${DJGPP_PREFIX}/bin/${TRIPLET}-djasm" \
 && cp -p ../hostbin/dxegen.exe "${DJGPP_PREFIX}/bin/${TRIPLET}-dxe3gen" \
 && cp -p dxe/dxe3res "${DJGPP_PREFIX}/bin/${TRIPLET}-dxe3res" \
 && ln -s "${TRIPLET}-djasm" "${DJGPP_PREFIX}/bin/djasm" \
 && ln -s "${TRIPLET}-dxe3gen" "${DJGPP_PREFIX}/bin/dxegen" \
 && ln -s "${TRIPLET}-dxe3gen" "${DJGPP_PREFIX}/bin/dxe3gen" \
 && ln -s "${TRIPLET}-dxe3res" "${DJGPP_PREFIX}/bin/dxe3res" \
 && cd /usr/src \
 && apt-get -y -q purge automake-1.15 texinfo zlib1g-dev && apt-get -y -q autoremove \
 && rm -rf /tmp/* /usr/src/* /var/lib/apt/lists/* /var/tmp/*

ENV DJDIR=$DJGPP_PREFIX/$TRIPLET
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && mv /opt/djgpp/MSDOS.cmake /usr/share/cmake-*/Modules/Platform/ \
 && cd /usr/src \
 && mkdir build-i586 && cd build-i586 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/djgpp/toolchain.cmake /opt/nxb/src/hello \
 && ninja && file ./hello.exe \
 && cd /usr/src && rm -rf /usr/src/*