package: flatbuffers
version: "v1.3.0"
source: https://github.com/google/flatbuffers
tag: v1.3.0
build_requires:
  - CMake
---
#!/bin/sh

cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      "$SOURCEDIR"

make ${JOBS+-j $JOBS}
make install

# Modulefile support
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
setenv FLATBUFFERS_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(FLATBUFFERS_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FLATBUFFERS_ROOT)/lib")
prepend-path PATH \$::env(FLATBUFFERS_ROOT)/bin
EoF
