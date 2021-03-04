FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL JAVA ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  openjdk-8-jdk-headless \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

ENV ANDROID_SDK_ROOT=/opt/android-sdk JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
 ANDROID_BUILD_TOOLS=30.0.3 ANDROID_PLATFORM_MIN=24 ANDROID_PLATFORM_TGT=28

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
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-${ANDROID_PLATFORM_MIN}" \
 && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} "platforms;android-${ANDROID_PLATFORM_TGT}" \
 && keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "C=US, O=Android, CN=Android Debug" \
 && apt-get remove -y \
  unzip \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk-bundle DEBUG_KEYSTORE=${ANDROID_SDK_ROOT}/debug.keystore \
 PATH=${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:$PATH \
 ANDROID_NDK_SYSROOT=${ANDROID_SDK_ROOT}/ndk-bundle/toolchains/llvm/prebuilt/linux-x86_64/sysroot
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && mv /usr/src/native_app_glue/CMakeLists.txt ${ANDROID_NDK_ROOT}/sources/android/native_app_glue/ \
 && cp -nv ${ANDROID_NDK_ROOT}/sources/android/native_app_glue/android_native_app_glue.h ${ANDROID_NDK_SYSROOT}/usr/include/android/native_app_glue.h \
 && rm -rf /usr/src/native_all_glue \
 && mkdir /tmp/nag-amd64 && cd /tmp/nag-amd64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-amd64.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/x86_64-linux-android/ \
 && mkdir /tmp/nag-arm64 && cd /tmp/nag-arm64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-arm64.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/aarch64-linux-android/ \
 && mkdir /tmp/nag-armv7 && cd /tmp/nag-armv7 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-armv7.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/arm-linux-androideabi/ \
 && mkdir /tmp/nag-ia32 && cd /tmp/nag-ia32 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-ia32.cmake ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/i686-linux-android/ \
 && git -C /usr/src clone https://code.nephatrine.net/nephatrine/hello-test.git \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-amd64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-arm64.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-armv7 && cd /tmp/build-armv7 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-armv7.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-ia32.cmake /usr/src/hello-test \
 && ninja && file HelloTest \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*
