package: ICU
version: "v53.1"
tag: "icu4c-53_1"
source: https://github.com/FairRootGroup/icu
requires:
 - "GCC-Toolchain:(?!osx)"
 ---
#!/bin/sh

$SOURCEDIR/source/configure --prefix=$INSTALLROOT CFLAGS="$CFLAGS" CXXFLAGS="$CFLAGS"
make ${JOBS+-j $JOBS}
make install

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
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
setenv ICU_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(ICU_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(ICU_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ICU_ROOT)/lib")
EoF
