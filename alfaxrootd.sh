package: AlfaXRootD
version: "%(tag_basename)s"
tag: v4.1.1
source: https://github.com/xrootd/xrootd
build_requires:
  - CMake
---
##!/bin/sh

case $ARCHITECTURE in
  osx*) if clang --version | grep -q "version 7" ; then
          krb5="-DENABLE_KRB5=FALSE -DENABLE_CRYPTO=FALSE"
        else
          krb5="ENABLE_KRB5=TRUE-DENABLE_CRYPTO=TRUE"
        fi
        ;;
esac


cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_INSTALL_LIBDIR=$INSTALLROOT/lib \
      $krb5 \
      $SOURCEDIR

make ${JOBS+-j $JOBS}
make install
