package: vgm
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v4-4"
source: https://github.com/vmc-project/vgm
requires:
  - ROOT
  - GEANT4
build_requires:
  - CMake
---
#!/bin/bash -e
cmake                                                    \
   ${_C_COMPILER:+-DCMAKE_C_COMPILER=$_C_COMPILER}       \
   ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}              \
   ${_CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$_CXX_COMPILER} \
   ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}        \
   ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}       \
  -DCMAKE_INSTALL_LIBDIR="lib"                           \
  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"                  \
  "$SOURCEDIR"

make ${JOBS+-j $JOBS} install VERBOSE=1

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "ALICE Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 GEANT4/$GEANT4_VERSION-$GEANT4_REVISION ROOT/$ROOT_VERSION-$ROOT_REVISION
# Our environment
setenv VGM_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(VGM_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(VGM_ROOT)/lib")
EoF
