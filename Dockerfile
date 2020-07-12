FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

ENV ANDROID_SDK_ROOT=/opt/android-sdk ANDROID_SDK_TOOLS=29.0.3 JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk-bundle DEBUG_KEYSTORE=${ANDROID_SDK_ROOT}/debug.keystore \
 PATH=${ANDROID_SDK_ROOT}/build-tools/${ANDROID_SDK_TOOLS}:${ANDROID_SDK_ROOT}/tools/bin:$PATH
ENV ANDROID_NDK_SYSROOT=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot
COPY override /

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install openjdk-8-jdk-headless \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*

RUN echo "====== INSTALL ANDROID SDK ======" \
 && export ANDROID_SDK_VERSION=4333796 \
 && cd ${ANDROID_SDK_ROOT} \
 && wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
 && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
 && rm -f sdk-tools-linux-${ANDROID_SDK_VERSION}.zip

RUN echo "====== INSTALL SDK TOOLS ======" \
 && mkdir /root/.android && touch /root/.android/repositories.cfg \
 && mv ${ANDROID_NDK_ROOT} ${ANDROID_SDK_ROOT}/ndk-bundle2 \
 && sdkmanager --update \
 && yes | sdkmanager --licenses \
 && sdkmanager "build-tools;${ANDROID_SDK_TOOLS}" \
 && sdkmanager "ndk-bundle" \
 && sdkmanager "platforms;android-19" \
 && sdkmanager "platforms;android-24" \
 && cp -nrv ${ANDROID_SDK_ROOT}/ndk-bundle2/* ${ANDROID_NDK_ROOT}/ \
 && rm -rf /tmp/* /var/tmp/* /usr/src/* ${ANDROID_SDK_ROOT}/ndk-bundle2

RUN echo "====== INSTALL NATIVE_APP_GLUE ======" \
 && cp -nv ${ANDROID_NDK_ROOT}/sources/android/native_app_glue/android_native_app_glue.h ${ANDROID_NDK_SYSROOT}/usr/include/android/native_app_glue.h \
 && mkdir /usr/src/native_app_glue \
 && cd /usr/src/native_app_glue \
 && mkdir build-arm && cd build-arm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=19 -DANDROID_ABI=armeabi-v7a ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/arm-linux-androideabi/ \
 && cd /usr/src/native_app_glue \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=24 -DANDROID_ABI=arm64-v8a ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/aarch64-linux-android/ \
 && cd /usr/src/native_app_glue \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=19 -DANDROID_ABI=x86 ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/i686-linux-android/ \
 && cd /usr/src/native_app_glue \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=24 -DANDROID_ABI=x86_64 ${ANDROID_NDK_ROOT}/sources/android/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/x86_64-linux-android/ \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*

RUN echo "====== INSTALL DEBUG KEYSTORE ======" \
 && cd "${ANDROID_SDK_ROOT}" \
 && keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "C=US, O=Android, CN=Android Debug"

RUN echo "====== TEST TOOLCHAINS ======" \
 && mkdir /usr/src/nxbuild \
 && cd /usr/src/nxbuild \
 && mkdir build-arm && cd build-arm \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=19 -DANDROID_ABI=armeabi-v7a /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-aarch64 && cd build-aarch64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=24 -DANDROID_ABI=arm64-v8a /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-i686 && cd build-i686 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=19 -DANDROID_ABI=x86 /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src/nxbuild \
 && mkdir build-x86_64 && cd build-x86_64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK_ROOT}/toolchain.cmake -DANDROID_NATIVE_API_LEVEL=24 -DANDROID_ABI=x86_64 /opt/nxb/src/nxbuild \
 && ninja && ninja install \
 && cd /usr/src && rm -rf /tmp/* /var/tmp/* /usr/src/*