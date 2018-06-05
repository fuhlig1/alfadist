package: GEANT3
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v2-5-gcc8"
requires:
  - ROOT
build_requires:
  - CMake
  - "Xcode:(osx.*)"
source: https://github.com/FairRootGroup/geant3.git
tag: v2-5
prepend_path:
  "LD_LIBRARY_PATH": "$GEANT3_ROOT/lib64"
  "DYLD_LIBRARY_PATH": "$GEANT3_ROOT/lib64"
---
#!/bin/bash -e
cmake                                                                   \
      ${_C_COMPILER:+-DCMAKE_C_COMPILER=$_C_COMPILER      }             \
      ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}                          \
      ${_CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$_CXX_COMPILER}             \
      ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}                    \
      ${_Fortran_COMPILER:+-DCMAKE_Fortran_COMPILER=$_Fortran_COMPILER} \
      ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}                   \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                               \
      -DCMAKE_SKIP_RPATH=TRUE                                           \
      $SOURCEDIR

make ${JOBS:+-j $JOBS} install VERBOSE=1

[[ ! -d $INSTALLROOT/lib64 ]] && ln -sf lib $INSTALLROOT/lib64

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
module load BASE/1.0 ROOT/$ROOT_VERSION-$ROOT_REVISION
# Our environment
setenv GEANT3_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv GEANT3DIR \$::env(GEANT3_ROOT)
setenv G3SYS \$::env(GEANT3_ROOT)
prepend-path PATH \$::env(GEANT3_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(GEANT3_ROOT)/lib64
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GEANT3_ROOT)/lib64")
EoF
