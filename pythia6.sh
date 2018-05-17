# a pythia6 recipe based on the one from FairROOT
package: pythia6
version: "%(tag_basename)s%(defaults_upper)s"
tag: "alice/428"
source: https://github.com/alisw/pythia6.git
build_requires:
  - CMake
---
#!/bin/sh

cmake                                                                   \
      ${_C_COMPILER:+-DCMAKE_C_COMPILER=$_C_COMPILER}                   \
      ${_Fortran_COMPILER:+-DCMAKE_Fortran_COMPILER=$_Fortran_COMPILER} \
      ${_Fortran_FLAGS:+-DCMAKE_Fortran_FLAGS="$_Fortran_FLAGS"}        \
      ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}                          \
      ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}                   \
      -DCMAKE_INSTALL_PREFIX=${INSTALLROOT}                             \
      ${SOURCEDIR}

make ${JOBS+-j$JOBS}
make install
ln -s libpythia6.so $INSTALLROOT/lib/libPythia6.so

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
module load BASE/1.0
# Our environment
setenv PYTHIA6_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(PYTHIA6_ROOT)/lib
prepend-path AGILE_GEN_PATH \$::env(PYTHIA6_ROOT)
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(PYTHIA6_ROOT)/lib")
EoF

