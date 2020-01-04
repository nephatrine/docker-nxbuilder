FROM nephatrine/nxbuilder:latest
LABEL maintainer="Daniel Wolf <nephatrine@gmail.com>"

RUN echo "====== INSTALL PACKAGES ======" \
 && apt-get update -q \
 && apt-get -y -q -o Dpkg::Options::="--force-confnew" install \
   alien mock \
   crossbuild-essential-arm64 \
   crossbuild-essential-armhf \
   crossbuild-essential-ppc64el \
   crossbuild-essential-s390x \
   debhelper pbuilder \
   git-buildpackage git-buildpackage-rpm \
   mercurial-buildpackage \
   svn-buildpackage \
 && apt-get clean \
 && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
