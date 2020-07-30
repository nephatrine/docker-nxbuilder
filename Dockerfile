FROM nephatrine/nxbuilder:mingw
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV UniversalCRTSdkDir="${WINEPREFIX}/drive_c/Program Files (x86)/Windows Kits/10/" \
 VSINSTALLDIR="${WINEPREFIX}/drive_c/Program Files (x86)/Microsoft Visual Studio/2019/Community/"

RUN echo "====== INSTALL MSVC-WINE ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
  msitools \
  python3-simplejson \
 && git -C /usr/src clone --depth=1 https://github.com/mstorsjo/msvc-wine.git \
 && mkdir /tmp/msvc-staging && python3 /usr/src/msvc-wine/vsdownload.py --accept-license --dest /tmp/msvc-staging \
 && mkdir -p "${UniversalCRTSdkDir}" && mv /tmp/msvc-staging/kits/10/* "${UniversalCRTSdkDir}" && rm -rf /tmp/msvc-staging/kits \
 && find "${UniversalCRTSdkDir}" -name 'arm' -type d -exec rm -rf {} + && find "${UniversalCRTSdkDir}" -name '*.exe' -type f -delete \
 && mkdir -p "${VSINSTALLDIR}" && mv /tmp/msvc-staging/* "${VSINSTALLDIR}" \
 && find "${VSINSTALLDIR}" -name 'arm' -type d -exec rm -rf {} + && find "${VSINSTALLDIR}" -name '*.exe' -type f -delete \
 && apt-get remove -y \
  msitools \
  python3-simplejson \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/msvc-wine
ENV UCRTVersion=10.0.18362.0 VCToolsVersion=14.26.28801 VCRedistVersion=14.26.28720
ENV VCINSTALLDIR="${VSINSTALLDIR}VC/" WindowsSDKLibVersion=${UCRTVersion}/ WindowsSDKVersion=${UCRTVersion}/ WindowsSdkDir="${UniversalCRTSdkDir}"
ENV VCToolsInstallDir="${VCINSTALLDIR}Tools/MSVC/${VCToolsVersion}/" VCToolsRedistDir="${VCINSTALLDIR}Redist/MSVC/${VCRedistVersion}/" \
 WindowsSdkBinPath="${WindowsSdkDir}bin/" WindowsSdkVerBinPath="${WindowsSdkDir}bin/${WindowsSDKVersion}"
COPY override /

RUN echo "====== BUILD COMPILER-RT ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  libclang-dev llvm-dev \
 && ls "${WindowsSdkVerBinPath}" && ls "${VCToolsRedistDir}" && ls "${VCToolsInstallDir}" \
 && find "${WindowsSdkVerBinPath}x64/ucrt" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/system32/ \
 && find "${WindowsSdkVerBinPath}x86/ucrt" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && find "${VCToolsRedistDir}x64" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/system32/ \
 && find "${VCToolsRedistDir}x86" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && find "${VCToolsRedistDir}debug_nonredist/x64" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/system32/ \
 && find "${VCToolsRedistDir}debug_nonredist/x86" -name '*.dll' -type f | xargs -I{} cp -nvs {} ${WINEPREFIX}/drive_c/windows/syswow64/ \
 && git -C /usr/src clone --depth=1 --branch "release/${LLVM_MAJOR}.x" https://github.com/llvm/llvm-project.git \
 && cp -nrv /usr/src/llvm-project/compiler-rt/include/sanitizer /usr/lib/clang/${LLVM_MAJOR}/include/ \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-amd64.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="x86_64-pc-windows-msvc" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-arm64.cmake \
  -DCOMPILER_RT_BUILD_SANITIZERS=OFF -DCOMPILER_RT_BUILD_XRAY=OFF -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="aarch64-pc-windows-msvc" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/windows/*.lib /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-ia32.cmake \
  -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE="i686-pc-windows-msvc" /usr/src/llvm-project/compiler-rt \
 && ninja && cp -nv ./lib/windows/*.lib ./lib/windows/*.dll /usr/lib/clang/${LLVM_MAJOR}/lib/windows/ \
 && apt-get remove -y \
  libclang-dev llvm-dev \
 && apt-get autoremove -y \
 && apt-get clean \
 && cd /tmp && rm -rf /tmp/* /var/tmp/* /usr/src/llvm-project

RUN echo "====== TEST TOOLCHAINS ======" \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-amd64.cmake /usr/src/hello \
 && ninja && ${WINE} ./hello-test.exe \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-arm64.cmake /usr/src/hello \
 && ninja && file hello-test.exe \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/windows-ia32.cmake /usr/src/hello \
 && ninja && ${WINE} ./hello-test.exe \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*