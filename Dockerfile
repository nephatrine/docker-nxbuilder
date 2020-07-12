FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV DJGPP_PREFIX=/opt/cross-tools/msdos
ENV DJDIR=${DJGPP_PREFIX}/i586-pc-msdosdjgpp PATH=${DJGPP_PREFIX}/bin:$PATH
COPY override /
RUN mv /opt/cross-tools/msdos/MSDOS.cmake /usr/share/cmake-*/Modules/Platform/

RUN echo "====== INSTALL BINUTILS ======" \
 && export BINTUILS_MAJOR=2 && export BINTUILS_MINOR=34 \
 && cd /usr/src \
 && mkdir "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s" && cd "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s" \
 && curl -f "http://na.mirror.garr.it/mirrors/djgpp/current/v2gnu/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" -L -o "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" \
 && unzip -oq "bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" \
 && cd "gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}" \
 && chmod +x install-sh && chmod +x missing && chmod +x configure \
 && mkdir build && cd build \
 && ../configure --target=i586-pc-msdosdjgpp --prefix=${DJGPP_PREFIX} --disable-werror --disable-nls \
 && make -j4 configure-bfd && make -j4 -C bfd stmp-lcoff-h \
 && make -j4 && make -j4 -s check && make install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== INSTALL GCC ======" \
 && export GCC_MAJOR=9 && export GCC_MINOR=3 \
 && export GMP_VERSION=6.2.0 && export ISL_VERSION=0.22.1 \
 && export MPC_VERSION=1.1.0 && export MPFR_VERSION=4.0.2 \
 && update-alternatives --set automake /usr/bin/automake-1.15 \
 && cd /usr/src \
 && git clone https://github.com/jwt27/djgpp-cvs.git "/usr/src/djgpp-cvs" && cd "djgpp-cvs/src" \
 && sed -i 's/Werror/Wno-error/g' makefile.cfg \
 && make misc.exe makemake.exe \
 && make ../hostbin \
 && make -C djasm native \
 && make -C stub native \
 && mkdir -p "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/sys-include" \
 && cp -rp ../include/* "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/sys-include/" \
 && mkdir -p "${DJGPP_PREFIX}/bin" \
 && cp -p ../hostbin/stubify.exe "${DJGPP_PREFIX}/bin/i586-pc-msdosdjgpp-stubify" \
 && cp -p ../hostbin/stubedit.exe "${DJGPP_PREFIX}/bin/i586-pc-msdosdjgpp-stubedit" \
 && ln -s "i586-pc-msdosdjgpp-stubify" "${DJGPP_PREFIX}/bin/stubify" \
 && ln -s "i586-pc-msdosdjgpp-stubedit" "${DJGPP_PREFIX}/bin/stubedit" \
 && cd /usr/src \
 && curl -f "http://na.mirror.garr.it/mirrors/djgpp/rpms/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0/djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2" -L -o "djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2" \
 && tar xjf "djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.bz2" && cd "djcross-gcc-${GCC_MAJOR}.${GCC_MINOR}.0" \
 && curl -f "http://ftpmirror.gnu.org/gcc/gcc-${GCC_MAJOR}.${GCC_MINOR}.0/gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz" -L -o "gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz" \
 && sh unpack-gcc.sh --no-djgpp-source "gcc-${GCC_MAJOR}.${GCC_MINOR}.0.tar.xz" \
 && curl -f "http://ftpmirror.gnu.org/gmp/gmp-${GMP_VERSION}.tar.xz" -L -o "gmp-${GMP_VERSION}.tar.xz" \
 && tar xJf "gmp-${GMP_VERSION}.tar.xz" && mv "gmp-${GMP_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/gmp" \
 && curl -f "http://ftpmirror.gnu.org/mpfr/mpfr-${MPFR_VERSION}.tar.xz" -L -o "mpfr-${MPFR_VERSION}.tar.xz" \
 && tar xJf "mpfr-${MPFR_VERSION}.tar.xz" && mv "mpfr-${MPFR_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/mpfr" \
 && curl -f "http://ftpmirror.gnu.org/mpc/mpc-${MPC_VERSION}.tar.gz" -L -o "mpc-${MPC_VERSION}.tar.gz" \
 && tar xzf "mpc-${MPC_VERSION}.tar.gz" && mv "mpc-${MPC_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/mpc" \
 && curl -f "http://isl.gforge.inria.fr/isl-${ISL_VERSION}.tar.xz" -L -o "isl-${ISL_VERSION}.tar.xz" \
 && tar xJf "isl-${ISL_VERSION}.tar.xz" && mv "isl-${ISL_VERSION}" "gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/isl" \
 && mkdir djcross && cd djcross \
 && ../gnu/gcc-${GCC_MAJOR}.${GCC_MINOR}0/configure --disable-plugin --enable-lto --disable-nls --enable-libquadmath-support --enable-version-specific-runtime-libs --enable-fat --enable-libstdcxx-filesystem-ts --target=i586-pc-msdosdjgpp --prefix=${DJGPP_PREFIX} --enable-languages=c,c++ \
 && make -j4 all-gcc && make install-gcc \
 && cd "/usr/src/djgpp-cvs/src" \
 && make config \
 && make -j4 -C mkdoc \
 && make -j4 -C libc \
 && mkdir -p "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/lib" \
 && cp -rp ../lib/* "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/lib/" \
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
 && cp -rp ../lib/* "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/lib/" \
 && mkdir -p "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/share/info" \
 && cp -rp ../info/* "${DJGPP_PREFIX}/i586-pc-msdosdjgpp/share/info/" \
 && cp -p ../hostbin/djasm.exe "${DJGPP_PREFIX}/bin/i586-pc-msdosdjgpp-djasm" \
 && cp -p ../hostbin/dxegen.exe "${DJGPP_PREFIX}/bin/i586-pc-msdosdjgpp-dxe3gen" \
 && cp -p dxe/dxe3res "${DJGPP_PREFIX}/bin/i586-pc-msdosdjgpp-dxe3res" \
 && ln -s "i586-pc-msdosdjgpp-djasm" "${DJGPP_PREFIX}/bin/djasm" \
 && ln -s "i586-pc-msdosdjgpp-dxe3gen" "${DJGPP_PREFIX}/bin/dxegen" \
 && ln -s "i586-pc-msdosdjgpp-dxe3gen" "${DJGPP_PREFIX}/bin/dxe3gen" \
 && ln -s "i586-pc-msdosdjgpp-dxe3res" "${DJGPP_PREFIX}/bin/dxe3res" \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-i586 && cd build-i586 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/msdos/toolchain.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*