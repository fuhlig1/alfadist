package: flatbuffers
version: v1.9.0-fairroot
source: https://github.com/FairRootGroup/flatbuffers
requires:
  - zlib
build_requires:
 - CMake
 - "GCC-Toolchain:(?!osx)"
prefer_system: "(?!slc5)"
prefer_system_check: |
  printf "#include <flatbuffers/flatbuffers.h>\n#define VERSION (FLATBUFFERS_VERSION_MAJOR * 10000) + (FLATBUFFERS_VERSION_MINOR * 100) + FLATBUFFERS_VERSION_REVISION\n#if(VERSION < 10701)\n#error \"flatbuffers version >= 1.7.1 needed\"\n#endif\nint main(){}" | c++ -I$(brew --prefix flatbuffers)/include -xc++ -std=c++11 - -o /dev/null
---
mkdir -p $INSTALLROOT
cmake $SOURCEDIR                              \
      ${C_COMPILER:+-DCMAKE_C_COMPILER=$C_COMPILER}              \
      ${CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$CXX_COMPILER}        \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

cmake --build . --target install ${JOBS:+-- -j$JOBS}

#ModuleFile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
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
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
