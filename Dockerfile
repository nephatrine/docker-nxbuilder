FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   alien debhelper \
   crossbuild-essential-arm64 crossbuild-essential-armhf crossbuild-essential-ppc64el crossbuild-essential-s390x \
   git-buildpackage git-buildpackage-rpm mercurial-buildpackage svn-buildpackage \
   gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY override /
