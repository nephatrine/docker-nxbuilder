FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG ENABLE_LANGUAGES=c,c++
ARG DJGPP_MIRROR=http://mirrors/meowrnet/djgpp
ARG BINTUILS_MAJOR=2
ARG BINTUILS_MINOR=34

ENV DJGPP_PREFIX=/opt/djgpp
RUN echo "====== BUILD DJGPP ======" \
 && cd /usr/src \
 && curl -f "${DJGPP_MIRROR}/v2gnu/bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" -L -o bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip \
 && mkdir bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s && cd bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s \
 && unzip "../bnu${BINTUILS_MAJOR}${BINTUILS_MINOR}s.zip" \
 && cd "gnu/binutils-${BINTUILS_MAJOR}.${BINTUILS_MINOR}" \
 && chmod +x install-sh && chmod +x missing \
 && bash ./configure --prefix=${DJGPP_PREFIX} --target=i586-pc-msdosdjgpp --disable-werror --disable-nls \
 && make configure-bfd && make -C bfd stmp-lcoff-h && make && make install

ENV PATH=$DJGPP_PREFIX/bin:$PATH
