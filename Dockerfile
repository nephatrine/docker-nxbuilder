FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG DJGPP_MIRROR=http://mirrors.meowr.net/djgpp
ARG ENABLE_LANGUAGES=c,c++
ARG BINTUILS_MAJOR=2
ARG BINTUILS_MINOR=34

RUN echo "====== BUILD TEMPORARY HERE ======" \
 && cd /usr/src \
 && curl -f "${DJGPP_MIRROR}/v2gnu/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" -L -o bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip

ENV DJGPP_PREFIX=/opt/djgpp
RUN echo "====== BUILD DJGPP ======" \
 && cd /usr/src \
 && apt-get update -q \
 && apt-get -y -q -o DPkg::Options::="--force-confnew" install makeinfo \
 && mkdir bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s && cd bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s \
 && unzip "../bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" \
 && cd "gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}" \
 && chmod +x install-sh && chmod +x missing \
 && bash ./configure --prefix=${DJGPP_PREFIX} --target=i586-pc-msdosdjgpp --disable-werror --disable-nls \
 && make -j4 configure-bfd && make -j4 -C bfd stmp-lcoff-h && make -j4 && make install \
 && apt-get -y -q purge makeinfo \
 && apt-get -y -q autoremove \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/lib/apt/lists/* /var/tmp/*
ENV PATH=$DJGPP_PREFIX/bin:$PATH
