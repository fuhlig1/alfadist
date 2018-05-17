package: HepMC
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/alisw/hepmc
tag: alice/v2.06.09
build_requires:
  - CMake
---
#!/bin/bash -e

cmake                                                        \
       -Dmomentum=GEV                                        \
       -Dlength=MM                                           \
       -Dbuild_docs:BOOL=OFF                                 \
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
module load BASE/1.0 ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv HEPMC_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(HEPMC_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(HEPMC_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(HEPMC_ROOT)/lib")
EoF
