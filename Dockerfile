FROM nephatrine/nxbuilder:mingw
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV UniversalCRTSdkDir="${WINEPREFIX}/drive_c/Program Files (x86)/Windows Kits/10/" \
 VSINSTALLDIR="${WINEPREFIX}/drive_c/Program Files (x86)/Microsoft Visual Studio/2019/Community/"

RUN echo "====== INSTALL MSVC-WINE ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
 && apt-get -y -o Dpkg::Options::="--force-confnew" install \
  msitools \
  python3-simplejson \
 && git -C /usr/src clone --single-branch --depth=1 https://github.com/mstorsjo/msvc-wine.git \
 && mkdir /tmp/msvc-staging && python3 /usr/src/msvc-wine/vsdownload.py --accept-license --dest /tmp/msvc-staging \
  Microsoft.Component.VC.Runtime.UCRTSDK \
  Microsoft.VisualCpp.ASAN.X86 \
  Microsoft.VisualCpp.CLI.ARM64 \
  Microsoft.VisualCpp.CLI.Source \
  Microsoft.VisualCpp.CLI.X64 \
  Microsoft.VisualCpp.CLI.X86 \
  Microsoft.VisualCpp.CRT.Headers \
  Microsoft.VisualCpp.CRT.Redist.ARM64 \
  Microsoft.VisualCpp.CRT.Redist.Resources \
  Microsoft.VisualCpp.CRT.Redist.X64 \
  Microsoft.VisualCpp.CRT.Redist.X86 \
  Microsoft.VisualCpp.CRT.Redist.arm64.OneCore.Desktop \
  Microsoft.VisualCpp.CRT.Redist.x64.OneCore.Desktop \
  Microsoft.VisualCpp.CRT.Redist.x86.OneCore.Desktop \
  Microsoft.VisualCpp.CRT.Source \
  Microsoft.VisualCpp.CRT.arm64.Desktop \
  Microsoft.VisualCpp.CRT.arm64.OneCore.Desktop \
  Microsoft.VisualCpp.CRT.arm64.Store \
  Microsoft.VisualCpp.CRT.x64.Desktop \
  Microsoft.VisualCpp.CRT.x64.OneCore.Desktop \
  Microsoft.VisualCpp.CRT.x64.Store \
  Microsoft.VisualCpp.CRT.x86.Desktop \
  Microsoft.VisualCpp.CRT.x86.OneCore.Desktop \
  Microsoft.VisualCpp.CRT.x86.Store \
  Microsoft.VisualCpp.PGO.ARM64 \
  Microsoft.VisualCpp.PGO.Headers \
  Microsoft.VisualCpp.PGO.X64 \
  Microsoft.VisualCpp.PGO.X86 \
  Microsoft.VisualStudio.Component.Windows10SDK \
  Microsoft.VisualStudio.Component.Windows10SDK.19041 \
  Microsoft.VisualStudio.VC.Llvm.Base \
  Microsoft.VisualStudio.VC.Llvm.Clang \
 && mkdir -p "${UniversalCRTSdkDir}" && mv /tmp/msvc-staging/kits/10/* "${UniversalCRTSdkDir}" && rm -rf /tmp/msvc-staging/kits \
 && find "${UniversalCRTSdkDir}" -name 'arm' -type d -exec rm -rf {} + && find "${UniversalCRTSdkDir}" -name '*.exe' -type f -delete \
 && mkdir -p "${VSINSTALLDIR}" && mv /tmp/msvc-staging/* "${VSINSTALLDIR}" \
 && find "${VSINSTALLDIR}" -name 'arm' -type d -exec rm -rf {} + && find "${VSINSTALLDIR}" -name '*.exe' -type f -delete \
 && apt-get remove -y \
  msitools \
  python3-simplejson \
 && apt-get autoremove -y && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/*

ENV UCRTVersion=10.0.19041.0 VCToolsVersion=14.29.30037 VCRedistVersion=14.29.30036 \
 VCINSTALLDIR="${VSINSTALLDIR}VC/" WindowsSdkDir="${UniversalCRTSdkDir}" WindowsSdkBinPath="${UniversalCRTSdkDir}bin/"
ENV VCToolsInstallDir="${VCINSTALLDIR}Tools/MSVC/${VCToolsVersion}/" VCToolsRedistDir="${VCINSTALLDIR}Redist/MSVC/${VCRedistVersion}/" \
 WindowsSDKLibVersion=${UCRTVersion}/ WindowsSdkVerBinPath="${WindowsSdkDir}bin/${UCRTVersion}/" WindowsSDKVersion=${UCRTVersion}/
COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && ls "${WindowsSdkDir}bin" && ls "${WindowsSdkVerBinPath}" \
 && ls "${VCINSTALLDIR}Redist/MSVC" && ls "${VCToolsRedistDir}" \
 && ls "${VCINSTALLDIR}Tools/MSVC" && ls "${VCToolsInstallDir}" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends llvm-${LLVM_MAJOR}-dev \
 && find "${WindowsSdkVerBinPath}x64/ucrt" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/system32/ \
 && find "${WindowsSdkVerBinPath}x86/ucrt" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && find "${VCToolsRedistDir}x64" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/system32/ \
 && find "${VCToolsRedistDir}x86" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && find "${VCToolsRedistDir}debug_nonredist/x64" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/system32/ \
 && find "${VCToolsRedistDir}debug_nonredist/x86" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && git -C /usr/src clone --single-branch --depth=1 -b "release/${LLVM_MAJOR}.x" https://github.com/llvm/llvm-project.git \
 && cp -nrv /usr/src/llvm-project/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && mkdir /tmp/build-x64 && cd /tmp/build-x64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.x64.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-pc-windows-msvc" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.arm64.cmake \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="aarch64-pc-windows-msvc" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/windows/*.lib /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && mkdir /tmp/build-x86 && cd /tmp/build-x86 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.x86.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="i686-pc-windows-msvc" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && apt-get remove -y llvm-${LLVM_MAJOR}-dev \
 && apt-get autoremove -y && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-x64 && cd /tmp/build-x64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.x64.cmake /usr/src/hello-test \
 && ninja && ${WINE} ./HelloTest.exe \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.arm64.cmake /usr/src/hello-test \
 && ninja && file HelloTest.exe \
 && mkdir /tmp/build-x86 && cd /tmp/build-x86 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=${WINDOWS_TOOLCHAIN}/toolchain.x86.cmake /usr/src/hello-test \
 && ninja && ${WINE} ./HelloTest.exe \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
