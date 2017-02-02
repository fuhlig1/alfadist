package: Millepede
version: "V04-03-04"
source: https://github.com/FairRootGroup/Millepede
tag: alfa/V04-03-04
---
##!/bin/sh
rsync -a --exclude '**/.git' --delete $SOURCEDIR/ $BUILDDIR

case $ARCHITECTURE in
  osx*)
    fortran_filepath=$(gfortran -print-file-name=libgfortran.dylib)
    fortran_libdir=-L$(dirname $fortran_filepath)
    echo $fortran_libdir
    ;;
  *)
    fortran_libdir=" "
    ;;  
esac

echo "LIBDIR: $fortran_libdir"
  
fortran_libdir=$fortran_libdir FC=$FC make

# fake make install
mkdir -p $INSTALLROOT/bin
cp pede $INSTALLROOT/bin

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      $SOURCEDIR

make install ${JOBS+-j $JOBS}


