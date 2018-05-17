package: googletest
version: "1.8.0"
source: https://github.com/google/googletest
tag: release-1.8.0
build_requires:
 - CMake
---
#!/bin/sh
cmake                                                       \
      ${_C_COMPILER:+-DCMAKE_C_COMPILER=$_C_COMPILER}       \
      ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}              \
      ${_CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$_CXX_COMPILER} \
      ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}        \
      ${_CXX_STANDARD:+-DCMAKE_CXX_STANDARD=$_CXX_STANDARD} \
      ${_CXX_STANDARD:+-DCMAKE_CXX_STANDARD_REQUIRED=YES}   \
      ${_CXX_STANDARD:+-DCMAKE_CXX_EXTENSIONS=NO}           \
      ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}       \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                   \
      $SOURCEDIR

make VERBOSE=1 ${JOBS+-j $JOBS}
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
