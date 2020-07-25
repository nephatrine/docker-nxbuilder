FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL JAVA ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  openjdk-8-jdk-headless \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*
ENV ANDROID_SDK_ROOT=/opt/android-sdk JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
 ANDROID_NDK_SYSROOT=/opt/sysroot-android ANDROID_BUILD_TOOLS=29.0.3 ANDROID_PLATFORM=24

RUN echo "====== INSTALL ANDROID SDK ======" \
 && export DEBIAN_FRONTEND=noninteractive && apt-get update -q \
 && apt-get -o Dpkg::Options::="--force-confnew" install -y --no-install-recommends \
  unzip \
 && export ANDROID_SDK_VERSION=4333796 \
 && wget -qO /tmp/android-sdk-${ANDROID_SDK_VERSION}.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip \
 && mkdir ${ANDROID_SDK_ROOT} && cd ${ANDROID_SDK_ROOT} \
 && unzip /tmp/android-sdk-${ANDROID_SDK_VERSION}.zip \
 && export PATH=${ANDROID_SDK_ROOT}/tools/bin:$PATH \
 && mkdir /root/.android && touch /root/.android/repositories.cfg \
 && sdkmanager --update \
 && yes | sdkmanager --licenses \
 && sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" \
 && sdkmanager "ndk-bundle" \
 && sdkmanager "platforms;android-${ANDROID_PLATFORM}" \
 && keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "C=US, O=Android, CN=Android Debug" \
 && apt-get remove -y \
  unzip \
 && apt-get autoremove -y \
 && apt-get clean \
 && rm -rf /tmp/* /var/tmp/*
ENV ANDROID_NDK_ROOT=${ANDROID_SDK_ROOT}/ndk-bundle DEBUG_KEYSTORE=${ANDROID_SDK_ROOT}/debug.keystore \
 PATH=${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS}:${ANDROID_SDK_ROOT}/tools/bin:$PATH
COPY override /

RUN echo "====== TEST TOOLCHAINS ======" \
 && ln -s ${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot ${ANDROID_NDK_SYSROOT} \
 && cp -nv ${ANDROID_NDK_ROOT}/sources/android/native_app_glue/android_native_app_glue.h ${ANDROID_NDK_SYSROOT}/usr/include/android/native_app_glue.h \
 && git -C /usr/src/nxbuild pull \
 && mkdir /tmp/nxbuild && cd /tmp/nxbuild \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-amd64.cmake /usr/src/nxbuild \
 && ninja && ninja install \
 && mkdir /tmp/build-amd64 && cd /tmp/build-amd64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-amd64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/nag-amd64 && cd /tmp/nag-amd64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-amd64.cmake /usr/src/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/x86_64-linux-android/ \
 && mkdir /tmp/build-arm64 && cd /tmp/build-arm64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-arm64.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/nag-arm64 && cd /tmp/nag-arm64 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-arm64.cmake /usr/src/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/aarch64-linux-android/ \
 && mkdir /tmp/build-armv7 && cd /tmp/build-armv7 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-armv7.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/nag-armv7 && cd /tmp/nag-armv7 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-armv7.cmake /usr/src/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/arm-linux-androideabi/ \
 && mkdir /tmp/build-ia32 && cd /tmp/build-ia32 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-ia32.cmake /usr/src/hello \
 && ninja && file hello-test \
 && mkdir /tmp/nag-ia32 && cd /tmp/nag-ia32 \
 && cmake -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=/opt/cross-tools/android-ia32.cmake /usr/src/native_app_glue \
 && ninja && cp -nv ./libnative_app_glue.a ${ANDROID_NDK_SYSROOT}/usr/lib/i686-linux-android/ \
 && cd /tmp && rm -rf /tmp/* /var/tmp/*