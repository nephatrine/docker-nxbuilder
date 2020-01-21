FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ARG SDK_VERSION=10.11
ARG TARGET_DIR=/osx-cross
RUN echo "====== DOWNLOAD OSX SDK ======" \
 && cd /usr/src \
 && git clone https://github.com/tpoechtrager/osxcross.git && cd osxcross \
 && wget https://files.nephatrine.net/Local/MacOSX${SDK_VERSION}.sdk.tar.xz -O tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz \
 && yes | ./build.sh && PATH="/osx-cross/bin:$PATH" ./build_compiler_rt.sh \
 && cd /usr/src && rm -rf /usr/src/*

COPY override /
RUN echo "====== UPDATE TOOLCHAINS ======" \
 && cd /osx-cross \
 && sed -i "s~MacOSXVERSION~MacOSX{SDK_VERSION}~g" /osx-cross/o32-toolchain.cmake \
 && sed -i "s~MacOSXVERSION~MacOSX{SDK_VERSION}~g" /osx-cross/o64-toolchain.cmake \
 && sed -i "s~MacOSXVERSION~MacOSX{SDK_VERSION}~g" /osx-cross/o64h-toolchain.cmake
