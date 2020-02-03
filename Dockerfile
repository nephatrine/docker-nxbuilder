FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install openjdk-8-jdk-headless \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENV ANDROID_SDK_ROOT=/opt/android-sdk ANDROID_SDK_VERSION=4333796
RUN echo "====== DOWNLOAD SDK ======" \
 && mkdir ${ANDROID_SDK_ROOT} && cd ${ANDROID_SDK_ROOT} \
 && wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
 && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
 && rm -f sdk-tools-linux-${ANDROID_SDK_VERSION}.zip
ENV PATH=${ANDROID_SDK_ROOT}/tools/bin:$PATH

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk-bundle ANDROID_NDK_VERSION=r21
RUN echo "====== DOWNLOAD SDK ADD-ONS ======" \
 && mkdir /root/.android && touch /root/.android/repositories.cfg \
 && sdkmanager --update \
 && yes | sdkmanager --licenses \
 && cd ${ANDROID_SDK_ROOT} \
 && wget https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && unzip android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && rm -f android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip \
 && mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_ROOT}

COPY override /

ENV NDK_SYSROOT=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot
RUN echo "====== BUILD NATIVE GLUE ======" \
 && cd /usr/src \
 && cp -nv ${ANDROID_NDK_ROOT}/sources/android/native_app_glue/android_native_app_glue.h ${NDK_SYSROOT}/usr/include/android/native_app_glue.h \
 && mkdir build-arm && cd build-arm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=armeabi-v7a ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${NDK_SYSROOT}/usr/lib/arm-linux-androideabi/ \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=arm64-v8a ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${NDK_SYSROOT}/usr/lib/aarch64-linux-android/ \
 && cd /usr/src \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=x86 ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${NDK_SYSROOT}/usr/lib/i686-linux-android/ \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=x86_64 ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${NDK_SYSROOT}/usr/lib/x86_64-linux-android/ \
 && cd /usr/src && rm -rf /usr/src/*

RUN echo "====== TEST TOOLCHAINS ======" \
 && cd /usr/src \
 && mkdir build-arm && cd build-arm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=armeabi-v7a /opt/nxb/src/hello \
 && ninja && file ./libhello.so \
 && cd /usr/src \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=arm64-v8a /opt/nxb/src/hello \
 && ninja && file ./libhello.so \
 && cd /usr/src \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=x86 /opt/nxb/src/hello \
 && ninja && file ./libhello.so \
 && cd /usr/src \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_ABI=x86_64 /opt/nxb/src/hello \
 && ninja && file ./libhello.so \
 && cd /usr/src && rm -rf /usr/src/*