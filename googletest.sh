package: googletest
version: "1.8.0"
source: https://github.com/google/googletest
tag: release-1.8.0
build_requires:
 - "GCC-Toolchain:(?!osx)"
 - CMake
---
#!/bin/sh
cmake                                                     \
      ${C_COMPILER:+-DCMAKE_C_COMPILER=$C_COMPILER}       \
      ${CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$CXX_COMPILER} \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                 \
      $SOURCEDIR

make ${JOBS+-j $JOBS}
make install

# Modulefile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0
# Our environment
setenv GOOGLETEST_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GTEST_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
