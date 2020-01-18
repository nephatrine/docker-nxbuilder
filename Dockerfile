FROM nephatrine/nxbuilder:mingw
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

#USER guardian
ENV WINEARCH=win64
ARG WINEDLLOVERRIDES="mscoree,mshtml="
RUN echo "====== CONFIGURE WINE (USER) ======" \
 && xvfb-run wine64 wineboot --init \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && xvfb-run winetricks -q dotnet40 dotnet_verifier hhw vcrun2015 \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && rm -rf /tmp/* /var/tmp/*
#USER root

RUN echo "====== DOWNLOAD WiX ======" \
 && mkdir /opt/wix && cd /opt/wix \
 && curl -SL "https://wixtoolset.org/downloads/v3.9.1006.0/wix39-binaries.zip" -o wix39-binaries.zip \
 && unzip wix39-binaries.zip \
 && chmod +x *.exe \
 && rm -f wix39-binaries.zip

ENV SDKVER="10.0.18362.0" MSVCVER="14.24.28314"
RUN echo "====== DOWNLOAD MSVC ======" \
 && mkdir /msvc && cd /usr/src \
 && git clone https://github.com/mstorsjo/msvc-wine.git && cd msvc-wine \
 && ./vsdownload.py --accept-license --dest /msvc \
 && ./install.sh /msvc \
 && mkdir /msvc/include \
 && cp -nrs /msvc/vc/tools/msvc/${MSVCVER}/include/* /msvc/include/ \
 && cp -nrs /msvc/kits/10/include/${SDKVER}/ucrt/* /msvc/include/ \
 && cp -nrs /msvc/kits/10/include/${SDKVER}/shared/* /msvc/include/ \
 && cp -nrs /msvc/kits/10/include/${SDKVER}/um/* /msvc/include/ \
 && cp -nrs /msvc/kits/10/include/${SDKVER}/cppwinrt/* /msvc/include/ \
 && mv /msvc/bin/x64 /msvc/x64/bin \
 && mkdir /msvc/x64/lib \
 && cp -nrs /msvc/vc/tools/msvc/${MSVCVER}/lib/x64/* /msvc/x64/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/ucrt/x64/* /msvc/x64/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/um/x64/* /msvc/x64/lib/ \
 && mv /msvc/bin/x86 /msvc/x86/bin \
 && mkdir /msvc/x86/lib \
 && cp -nrs /msvc/vc/tools/msvc/${MSVCVER}/lib/x86/* /msvc/x86/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/ucrt/x86/* /msvc/x86/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/um/x86/* /msvc/x86/lib/ \
 && mv /msvc/bin/arm /msvc/arm/bin \
 && mkdir /msvc/arm/lib \
 && cp -nrs /msvc/vc/tools/msvc/${MSVCVER}/lib/arm/* /msvc/arm/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/ucrt/arm/* /msvc/arm/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/um/arm/* /msvc/arm/lib/ \
 && mv /msvc/bin/arm64 /msvc/arm64/bin \
 && mkdir /msvc/arm64/lib \
 && cp -nrs /msvc/vc/tools/msvc/${MSVCVER}/lib/arm64/* /msvc/arm64/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/ucrt/arm64/* /msvc/arm64/lib/ \
 && cp -nrs /msvc/kits/10/lib/${SDKVER}/um/arm64/* /msvc/arm64/lib/ \
 && cd /usr/src && rm -rf /msvc/bin /tmp/* /usr/src/* /var/tmp/*

 COPY override /