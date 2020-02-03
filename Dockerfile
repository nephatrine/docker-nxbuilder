FROM nephatrine/nxbuilder:mingw
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG WINEDLLOVERRIDES="mscoree,mshtml="
RUN echo "====== CONFIGURE WINE (USER) ======" \
 && xvfb-run winetricks -q hhw vcrun2015 \
 && while pgrep wineserver >/dev/null; do sleep 1; done \
 && rm -rf /tmp/* /var/tmp/*

ENV WIX_DIR="${WINEPREFIX}/drive_c/Program Files (x86)/WiX Toolset v3.9/"
RUN echo "====== DOWNLOAD WiX ======" \
 && mkdir -p "${WIX_DIR}/bin" && cd "${WIX_DIR}/bin" \
 && curl -SL "https://wixtoolset.org/downloads/v3.9.1006.0/wix39-binaries.zip" -o wix39-binaries.zip \
 && unzip wix39-binaries.zip && chmod +x *.exe \
 && mv doc ../doc && mv sdk ../SDK \
 && rm -f wix39-binaries.zip

ENV VSINSTALLDIR="${WINEPREFIX}/drive_c/Program Files (x86)/Microsoft Visual Studio/2019/Community/"

ENV VCINSTALLDIR="${VSINSTALLDIR}VC/" VCToolsVersion="14.24.28314" VCRedistVersion="14.24.28127"
ENV VCToolsInstallDir="${VCINSTALLDIR}Tools/MSVC/${VCToolsVersion}/" VCToolsRedistDir="${VCINSTALLDIR}Redist/MSVC/${VCRedistVersion}/"

ENV UniversalCRTSdkDir="${WINEPREFIX}/drive_c/Program Files (x86)/Windows Kits/10/" UCRTVersion="10.0.18362.0"
ENV WindowsSdkDir="${UniversalCRTSdkDir}" WindowsSDKVersion="${UCRTVersion}/" WindowsSDKLibVersion="${UCRTVersion}/"
ENV WindowsSdkBinPath="${WindowsSdkDir}bin/" WindowsSdkVerBinPath="${WindowsSdkDir}bin/${WindowsSDKVersion}"

ARG TOOLCHAIN_PREFIX="/usr/src/staging"
RUN echo "====== DOWNLOAD MSVC ======" \
 && mkdir ${TOOLCHAIN_PREFIX} && cd /usr/src \
 && git clone https://github.com/mstorsjo/msvc-wine.git && cd msvc-wine \
 && ./vsdownload.py --accept-license --dest ${TOOLCHAIN_PREFIX} \
 && mkdir -p "${VSINSTALLDIR}" "${UniversalCRTSdkDir}" \
 && mv "${TOOLCHAIN_PREFIX}/DIA SDK" "${VSINSTALLDIR}" \
 && mv "${TOOLCHAIN_PREFIX}/VC" "${VSINSTALLDIR}" \
 && find "${VSINSTALLDIR}" -name arm -type d -exec rm -rf {} + \
 && find "${VSINSTALLDIR}" -name *.exe -type f -delete \
 && rm -rf "${UniversalCRTSdkDir}" && mv "${TOOLCHAIN_PREFIX}/kits/10/" "${UniversalCRTSdkDir}" \
 && find "${UniversalCRTSdkDir}" -name arm -type d -exec rm -rf {} + \
 && cd /usr/src && rm -rf /tmp/* /usr/src/* /var/tmp/*

COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && cd "${WindowsSdkVerBinPath}x64/ucrt" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/system32/ \
 && cd "${WindowsSdkVerBinPath}x86/ucrt" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && cd "${VCToolsRedistDir}x64/Microsoft.VC142.CRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/system32/ \
 && cd "${VCToolsRedistDir}x86/Microsoft.VC142.CRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && cd "${VCToolsRedistDir}debug_nonredist/x64/Microsoft.VC142.DebugCRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/system32/ \
 && cd "${VCToolsRedistDir}debug_nonredist/x86/Microsoft.VC142.DebugCRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && cd /usr/src \
 && git clone --single-branch --branch release_90 https://git.llvm.org/git/compiler-rt.git \
 && mkdir compiler-rt/build && cd compiler-rt/build \
 && cp -nrv ../include/sanitizer /usr/lib/clang/9.0.0/include/ \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-x86_64-msvc.cmake .. \
 && ninja \
 && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/9.0.0/lib/windows/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-i686-msvc.cmake .. \
 && ninja \
 && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/9.0.0/lib/windows/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-aarch64-msvc.cmake -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF .. \
 && ninja \
 && cp -nv ./lib/windows/*.lib /usr/lib/clang/9.0.0/lib/windows/ \
 && cd /usr/src && rm -rf /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-x86_64-msvc.cmake /opt/nxb/src/hello \
 && ninja && wine64 ./hello.exe \
 && cd /usr/src \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-i686-msvc.cmake /opt/nxb/src/hello \
 && ninja && wine ./hello.exe \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-aarch64-msvc.cmake /opt/nxb/src/hello \
 && ninja && file ./hello.exe \
 && cd /usr/src && rm -rf /usr/src/*