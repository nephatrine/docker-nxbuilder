FROM nephatrine/nxbuilder:mingw
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV UCRTVersion="10.0.18362.0" UniversalCRTSdkDir="${WINEPREFIX}/drive_c/Program Files (x86)/Windows Kits/10/" \
 VCToolsVersion="14.26.28801" VCRedistVersion="14.26.28720" VSINSTALLDIR="${WINEPREFIX}/drive_c/Program Files (x86)/Microsoft Visual Studio/2019/Community/"
ENV VCINSTALLDIR="${VSINSTALLDIR}VC/" WindowsSDKLibVersion="${UCRTVersion}/" WindowsSDKVersion="${UCRTVersion}/" WindowsSdkDir="${UniversalCRTSdkDir}"
ENV VCToolsInstallDir="${VCINSTALLDIR}Tools/MSVC/${VCToolsVersion}/" VCToolsRedistDir="${VCINSTALLDIR}Redist/MSVC/${VCRedistVersion}/" \
 WindowsSdkBinPath="${WindowsSdkDir}bin/" WindowsSdkVerBinPath="${WindowsSdkDir}bin/${WindowsSDKVersion}"
COPY override /

RUN echo "====== INSTALL MSVC-WINE ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install msitools \
 && mkdir /usr/src/staging && cd /usr/src \
 && git clone https://github.com/mstorsjo/msvc-wine.git && cd msvc-wine \
 && python3 ./vsdownload.py --accept-license --dest /usr/src/staging \
 && mkdir -p "${VSINSTALLDIR}" "${UniversalCRTSdkDir}" \
 && mv "/usr/src/staging/DIA SDK" "${VSINSTALLDIR}" \
 && mv "/usr/src/staging/VC" "${VSINSTALLDIR}" \
 && find "${VSINSTALLDIR}" -name arm -type d -exec rm -rf {} + \
 && find "${VSINSTALLDIR}" -name '*.exe' -type f -delete \
 && rm -rf "${UniversalCRTSdkDir}" && mv "/usr/src/staging/kits/10/" "${UniversalCRTSdkDir}" \
 && find "${UniversalCRTSdkDir}" -name arm -type d -exec rm -rf {} + \
 && find "${UniversalCRTSdkDir}" -name '*.exe' -type f -delete \
 && apt-get -y -q purge msitools \
 && apt-get -y -q autoremove \
 && apt-get clean \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== INSTALL COMPILER-RT ======" \
 && cd "${WindowsSdkVerBinPath}x64/ucrt" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/system32/ \
 && cd "${WindowsSdkVerBinPath}x86/ucrt" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && cd "${VCToolsRedistDir}x64/Microsoft.VC142.CRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/system32/ \
 && cd "${VCToolsRedistDir}x86/Microsoft.VC142.CRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && cd "${VCToolsRedistDir}debug_nonredist/x64/Microsoft.VC142.DebugCRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/system32/ \
 && cd "${VCToolsRedistDir}debug_nonredist/x86/Microsoft.VC142.DebugCRT" && cp -nv *.dll ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && cd /usr/src \
 && git clone --single-branch --branch "release/${LLVM_MAJOR}.x" https://github.com/llvm/llvm-project.git \
 && mkdir llvm-project/compiler-rt/build && cd llvm-project/compiler-rt/build \
 && cp -nrv ../include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_PREFIX/toolchain-x86_64-msvc.cmake -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-windows-msvc" .. \
 && ninja \
 && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_PREFIX/toolchain-i686-msvc.cmake -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="i686-windows-msvc" .. \
 && ninja \
 && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && rm -rf * \
 && cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=$TOOLCHAIN_PREFIX/toolchain-aarch64-msvc.cmake -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="aarch64-windows-msvc" .. \
 && ninja \
 && cp -nv ./lib/windows/*.lib /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-x86_64-msvc.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-i686-msvc.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/windows/cross-tools-llvm/toolchain-aarch64-msvc.cmake /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*