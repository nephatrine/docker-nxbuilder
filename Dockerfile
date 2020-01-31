FROM nephatrine/nxbuilder:mingw
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG WINEDLLOVERRIDES="mscoree,mshtml="
RUN echo "====== CONFIGURE WINE (USER) ======" \
 && xvfb-run winetricks -q dotnet40 dotnet_verifier hhw vcrun2015 \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== DOWNLOAD WiX ======" \
 && mkdir /opt/wix && cd /opt/wix \
 && curl -SL "https://wixtoolset.org/downloads/v3.9.1006.0/wix39-binaries.zip" -o wix39-binaries.zip \
 && unzip wix39-binaries.zip \
 && chmod +x *.exe \
 && rm -f wix39-binaries.zip

ARG TOOLCHAIN_PREFIX="/opt/msvc-wine"
RUN echo "====== DOWNLOAD MSVC ======" \
 && mkdir ${TOOLCHAIN_PREFIX} && cd /usr/src \
 && git clone https://github.com/mstorsjo/msvc-wine.git && cd msvc-wine \
 && ./vsdownload.py --accept-license --dest ${TOOLCHAIN_PREFIX} \
 && ./install.sh ${TOOLCHAIN_PREFIX} \
 && mkdir ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc \
 && mv ${TOOLCHAIN_PREFIX}/bin/x64 ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/bin \
 && mkdir ${TOOLCHAIN_PREFIX}/i686-windows-msvc \
 && mv ${TOOLCHAIN_PREFIX}/bin/x86 ${TOOLCHAIN_PREFIX}/i686-windows-msvc/bin \
 && mkdir ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc \
 && mv ${TOOLCHAIN_PREFIX}/bin/arm64 ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/bin \
 && mkdir ${TOOLCHAIN_PREFIX}/armv7-windows-msvc \
 && mv ${TOOLCHAIN_PREFIX}/bin/arm ${TOOLCHAIN_PREFIX}/armv7-windows-msvc/bin \
 && rm -rf ${TOOLCHAIN_PREFIX}/DIA\ SDK ${TOOLCHAIN_PREFIX}/bin \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

ENV SDKVER="10.0.18362.0" MSVCVER="14.24.28314"
RUN echo "====== CREATE SYMLINKS ======" \
 && mkdir -p ${TOOLCHAIN_PREFIX}/generic-windows-msvc/include \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/tools/msvc/${MSVCVER}/include/* ${TOOLCHAIN_PREFIX}/generic-windows-msvc/include/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/include/${SDKVER}/ucrt/* ${TOOLCHAIN_PREFIX}/generic-windows-msvc/include/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/include/${SDKVER}/shared/* ${TOOLCHAIN_PREFIX}/generic-windows-msvc/include/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/include/${SDKVER}/um/* ${TOOLCHAIN_PREFIX}/generic-windows-msvc/include/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/include/${SDKVER}/cppwinrt/* ${TOOLCHAIN_PREFIX}/generic-windows-msvc/include/ \
 && mkdir ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/lib \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/tools/msvc/${MSVCVER}/lib/x64/* ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/ucrt/x64/* ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/um/x64/* ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/bin/${SDKVER}/x64/ucrt/*.dll ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/bin/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/Redist/MSVC/14.24.28127/debug_nonredist/x64/Microsoft.VC142.DebugCRT/*.dll ${TOOLCHAIN_PREFIX}/x86_64-windows-msvc/bin/ \
 && mkdir ${TOOLCHAIN_PREFIX}/i686-windows-msvc/lib \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/tools/msvc/${MSVCVER}/lib/x86/* ${TOOLCHAIN_PREFIX}/i686-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/ucrt/x86/* ${TOOLCHAIN_PREFIX}/i686-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/um/x86/* ${TOOLCHAIN_PREFIX}/i686-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/bin/${SDKVER}/x86/ucrt/*.dll ${TOOLCHAIN_PREFIX}/i686-windows-msvc/bin/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/Redist/MSVC/14.24.28127/debug_nonredist/x86/Microsoft.VC142.DebugCRT/*.dll ${TOOLCHAIN_PREFIX}/i686-windows-msvc/bin/ \
 && mkdir ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/lib \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/tools/msvc/${MSVCVER}/lib/arm64/* ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/ucrt/arm64/* ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/um/arm64/* ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/bin/${SDKVER}/arm64/ucrt/*.dll ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/bin/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/Redist/MSVC/14.24.28127/debug_nonredist/arm64/Microsoft.VC142.DebugCRT/*.dll ${TOOLCHAIN_PREFIX}/aarch64-windows-msvc/bin/ \
 && mkdir ${TOOLCHAIN_PREFIX}/armv7-windows-msvc/lib \
 && cp -nrs ${TOOLCHAIN_PREFIX}/vc/tools/msvc/${MSVCVER}/lib/arm/* ${TOOLCHAIN_PREFIX}/armv7-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/ucrt/arm/* ${TOOLCHAIN_PREFIX}/armv7-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/lib/${SDKVER}/um/arm/* ${TOOLCHAIN_PREFIX}/armv7-windows-msvc/lib/ \
 && cp -nrs ${TOOLCHAIN_PREFIX}/kits/10/bin/${SDKVER}/arm/ucrt/*.dll ${TOOLCHAIN_PREFIX}/armv7-windows-msvc/bin/

COPY override /
