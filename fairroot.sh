package: FairRoot
version: "%(tag_basename)s"
tag: v-17.10_patches
source: https://github.com/FairRootGroup/FairRoot
requires:
  - FairSoft
env:
  VMCWORKDIR: "$FAIRROOT_ROOT/share/fairroot/examples"
  GEOMPATH:   "$FAIRROOT_ROOT/share/fairroot/examples/common/geometry"
  CONFIG_DIR: "$FAIRROOT_ROOT/share/fairroot/examples/common/gconfig"
prepend_path:
  ROOT_INCLUDE_PATH: "$FAIRROOT_ROOT/include"
incremental_recipe: |
  cmake --build . --target install ${JOBS:+-- -j$JOBS}
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/sh

case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
    [[ ! $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=`brew --prefix protobuf`
    [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
    SONAME=dylib
  ;;
  *) SONAME=so ;;
esac

unset SIMPATH

if [  -z "${DDS_LD_LIBRARY_PATH}" ]; then
  _UsePathInfo="-DUSE_PATH_INFO=NO"
else
  _UsePathInfo="-DUSE_PATH_INFO=TRUE"
fi

cmake                                                            \
      ${_C_COMPILER:+-DCMAKE_C_COMPILER=$_C_COMPILER}            \
      ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}                   \
      ${_CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$_CXX_COMPILER}      \
      ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}             \
      ${_CXX_STANDARD:+-DCMAKE_CXX_STANDARD=$_CXX_STANDARD}      \
      ${_CXX_STANDARD:+-DCMAKE_CXX_STANDARD_REQUIRED=YES}        \
      ${_CXX_STANDARD:+-DCMAKE_CXX_EXTENSIONS=NO}                \
      ${_UsePathInfo}                                            \
      -DFAIRROOT_MODULAR_BUILD=ON                                \
      -DMACOSX_RPATH=OFF                                         \
      -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                       \
      -DROOTSYS=$ROOTSYS                                         \
      -DROOT_CONFIG_SEARCHPATH=$ROOT_ROOT/bin                    \
      -DGTEST_ROOT=$GOOGLETEST_ROOT                              \
      -DDISABLE_GO=ON                                            \
      -DBUILD_EXAMPLES=ON                                        \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                        \
      -DFAIRROOT_MODULAR_BUILD=ON                                \
      $SOURCEDIR

cmake --build . ${JOBS:+-- -j$JOBS} VERBOSE=1
#ctest ${JOBS:+-j$JOBS}
cmake --build . --target install
#cmake --build . --target install ${JOBS:+-- -j$JOBS} VERBOSE=1

# Modulefile
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
module load BASE/1.0                                                                            \\
            FairSoft/$FAIRSOFT_VERSION-$FAIRSOFT_REVISION}                                      \\
# Our environment
setenv FAIRROOT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv VMCWORKDIR \$::env(FAIRROOT_ROOT)/share/fairbase/examples
setenv GEOMPATH \$::env(VMCWORKDIR)/common/geometry
setenv CONFIG_DIR \$::env(VMCWORKDIR)/common/gconfig
prepend-path PATH \$::env(FAIRROOT_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib
prepend-path ROOT_INCLUDE_PATH \$::env(FAIRROOT_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib")
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
