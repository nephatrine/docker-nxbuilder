[Git](https://code.nephatrine.net/nephatrine/docker-nxbuilder) |
[Docker](https://hub.docker.com/r/nephatrine/nxbuilder/)

[![Build Status](https://ci.nephatrine.net/api/badges/nephatrine/docker-nxbuilder/status.svg?ref=refs/heads/haiku)](https://ci.nephatrine.net/nephatrine/docker-nxbuilder)

# NXBuilder

This docker image contains the C++ build environment I use for projects. It is
intended to be used by a CI/CD service to perform builds and not kept running
beyond that. It can also be used as a quick "cleanroom" to test builds in.

- [Ubuntu Linux](https://ubuntu.com/)
- [GNU Compiler Collection](https://gcc.gnu.org/)
- [LLVM Clang](https://clang.llvm.org/)
- [CMake](https://cmake.org/)
- [Doxygen](http://www.doxygen.nl/)
- [M.CSS](https://mcss.mosra.cz/documentation/doxygen/)
- [TeX Live](https://www.tug.org/texlive/)

You can spin up a quick temporary test container like this:

~~~
docker run --rm -ti nephatrine/nxbuilder:latest /bin/sh
~~~

## Docker Tags

- **nephatrine/nxbuilder:latest**: Base Configuration
- **nephatrine/nxbuilder:android**: Build Android Packages
- **nephatrine/nxbuilder:beos**: Build Haiku Packages
- **nephatrine/nxbuilder:djgpp**: Build MS-DOS Packages
- **nephatrine/nxbuilder:linux**: Build Ubuntu Packages
- **nephatrine/nxbuilder:mingw**: Build Windows/MinGW Packages
- **nephatrine/nxbuilder:osx**: Build macOS/Darwin Packages
- **nephatrine/nxbuilder:unix**: Build FreeBSD/OpenIndiana Packages
- **nephatrine/nxbuilder:alpine**: Build Alpine Packages
- **nephatrine/nxbuilder:centos**: Build CentOS Packages
