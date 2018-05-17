package: ZeroMQ
version: "%(tag_basename)s"
tag: v4.2.5-fairroot
source: https://github.com/FairRootGroup/libzmq
build_requires:
  - CMake
prefer_system: (?!slc5.*)
prefer_system_check: |
  printf "#include <zmq.h>\n#if(ZMQ_VERSION < 40205)\n#error \"zmq version >= 4.2.5 needed\"\n#endif\n int main(){}" | gcc -I$(brew --prefix zeromq)/include $([[ -d $(brew --prefix zeromq) ]] || echo "-l:libzmq.a") -xc++ - -o /dev/null 2>&1
---
#!/bin/sh

mkdir -p $INSTALLROOT

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

cmake --build . ${JOBS:+-- -j$JOBS} VERBOSE=1
#ctest # Some tests fail, if run in parallel, so run sequentially ...
cmake --build . --target install


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
module load BASE/1.0 ${SODIUM_ROOT:+sodium/$SODIUM_VERSION-$SODIUM_REVISION} ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv ZEROMQ_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(ZEROMQ_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ZEROMQ_ROOT)/lib")
EoF
