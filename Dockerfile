FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL JAVA ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  openjdk-8-jdk-headless \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

ENV ANDROID_SDK_ROOT=/opt/android-sdk JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
 ANDROID_BUILD_TOOLS=30.0.3 ANDROID_PLATFORM=24 ANDROID_PLATFORM_EXTRA=28

RUN echo "====== INSTALL ANDROID SDK ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  unzip \
 && export ANDROID_SDK_VERSION=6858069 \
 && wget -qO /tmp/android-sdk-${ANDROID_SDK_VERSION}.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
 && mkdir ${ANDROID_SDK_ROOT} && cd ${ANDROID_SDK_ROOT} \
 && unzip /tmp/android-sdk-${ANDROID_SDK_VERSION}.zip \
 && mv cmdline-tools temp && mkdir cmdline-tools && mv temp cmdline-tools/ \
 && export PATH=${ANDROID_SDK_ROOT}/cmdline-tools/temp/bin:$PATH \
 && mkdir /root/.android && touch /root/.android/repositories.cfg \
 && sdkmanager --update --sdk_root=${ANDROID_SDK_ROOT} \
 && yes | sdkmanager --licenses --sdk_root=${ANDROID_SDK_ROOT} \
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "cmdline-tools;latest" \
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "build-tools;${ANDROID_BUILD_TOOLS}" \
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "ndk-bundle" \
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-${ANDROID_PLATFORM}" \
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-${ANDROID_PLATFORM_EXTRA}" \
 && keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "C=US, O=Android, CN=Android Debug" \
 && apt-get remove -y \
  unzip \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/* ${ANDROID_SDK_ROOT}/cmdline-tools/temp

#keytool -importkeystore -srckeystore debug.keystore -destkeystore debug.keystore -deststoretype pkcs12".

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk-bundle DEBUG_KEYSTORE=${ANDROID_SDK_ROOT}/debug.keystore \
 PATH=${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:$PATH
ENV ANDROID_NDK_SYSROOT=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot
COPY override /

RUN echo "====== BUILD NATIVE APP GLUE ======" \
 && cp -nv ${ANDROID_NDK_ROOT}/sources/android/native_app_glue/android_native_app_glue.h ${ANDROID_NDK_SYSROOT}/usr/include/android/native_app_glue.h \
 && mkdir /tmp/build-x86_64 && cd /tmp/build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.x86_64.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/x86_64-linux-android/ \
 && mkdir /tmp/build-arm64-v8a && cd /tmp/build-arm64-v8a \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.arm64-v8a.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/aarch64-linux-android/ \
 && mkdir /tmp/build-armeabi-v7a && cd /tmp/build-armeabi-v7a \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.armeabi-v7a.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/arm-linux-androideabi/ \
 && mkdir /tmp/build-x86 && cd /tmp/build-x86 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.x86.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/i686-linux-android/ \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*

RUN echo "====== TEST TOOLCHAIN ======" \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-x86_64 && cd /tmp/build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.x86_64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-arm64-v8a && cd /tmp/build-arm64-v8a \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.arm64-v8a.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-armeabi-v7a && cd /tmp/build-armeabi-v7a \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.armeabi-v7a.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-x86 && cd /tmp/build-x86 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.x86.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
