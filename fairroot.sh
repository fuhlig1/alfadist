package: FairRoot
version: "%(tag_basename)s"
tag: "alice-dev-20180110"
source: https://github.com/alisw/FairRoot
requires:
  - generators
  - simulation
  - ROOT
  - ZeroMQ
  - nanomsg
  - boost
  - protobuf
  - DDS
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - googletest
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

# Making sure people do not have SIMPATH set when they build fairroot.
# Unfortunately SIMPATH seems to be hardcoded in a bunch of places in
# fairroot, so this really should be cleaned up in FairRoot itself for
# maximum safety.
unset SIMPATH

case $ARCHITECTURE in
  osx*)
    # If we preferred system tools, we need to make sure we can pick them up.
    [[ ! $BOOST_ROOT ]] && BOOST_ROOT=`brew --prefix boost`
    [[ ! $ZEROMQ_ROOT ]] && ZEROMQ_ROOT=`brew --prefix zeromq`
    [[ ! $PROTOBUF_ROOT ]] && PROTOBUF_ROOT=`brew --prefix protobuf`
    [[ ! $NANOMSG_ROOT ]] && NANOMSG_ROOT=`brew --prefix nanomsg`
    [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
    SONAME=dylib
  ;;
  *) SONAME=so ;;
esac

[[ $BOOST_ROOT ]] && BOOST_NO_SYSTEM_PATHS=ON || BOOST_NO_SYSTEM_PATHS=OFF

cmake $SOURCEDIR                                                 \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS"                              \
      ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                    \
      ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}  \
      -DROOTSYS=$ROOTSYS                                         \
      -DDISABLE_GO=ON                                            \
      -DBUILD_EXAMPLES=OFF                                       \
      -DBoost_NO_SYSTEM_PATHS=${BOOST_NO_SYSTEM_PATHS}           \
      -DGTEST_ROOT=$GOOGLETEST_ROOT                              \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

# Limit the number of build processes to avoid exahusting memory when building
# on smaller machines.
# JOBS=$((${JOBS:-1}*2/5))
# [[ $JOBS -gt 0 ]] || JOBS=1
cmake --build . --target install ${JOBS:+-- -j$JOBS}

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
            ${GEANT3_VERSION:+GEANT3/$GEANT3_VERSION-$GEANT3_REVISION}                          \\
            ${GEANT4_VMC_VERSION:+GEANT4_VMC/$GEANT4_VMC_VERSION-$GEANT4_VMC_REVISION}          \\
            ${PROTOBUF_VERSION:+protobuf/$PROTOBUF_VERSION-$PROTOBUF_REVISION}                  \\
            ${PYTHIA6_VERSION:+pythia6/$PYTHIA6_VERSION-$PYTHIA6_REVISION}                      \\
            ${PYTHIA_VERSION:+pythia/$PYTHIA_VERSION-$PYTHIA_REVISION}                          \\
            ${VGM_VERSION:+vgm/$VGM_VERSION-$VGM_REVISION}                                      \\
            ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION}                              \\
            ROOT/$ROOT_VERSION-$ROOT_REVISION                                                   \\
            ${ZEROMQ_VERSION:+ZeroMQ/$ZEROMQ_VERSION-$ZEROMQ_REVISION}                          \\
            ${NANOMSG_VERSION:+nanomsg/$NANOMSG_VERSION-$NANOMSG_REVISION}                      \\
            ${DDS_ROOT:+DDS/$DDS_VERSION-$DDS_REVISION}                                         \\
            ${GCC_TOOLCHAIN_ROOT:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}
# Our environment
setenv FAIRROOT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv VMCWORKDIR \$::env(FAIRROOT_ROOT)/share/fairroot/examples
setenv GEOMPATH \$::env(VMCWORKDIR)/common/geometry
setenv CONFIG_DIR \$::env(VMCWORKDIR)/common/gconfig
prepend-path PATH \$::env(FAIRROOT_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib
prepend-path ROOT_INCLUDE_PATH \$::env(FAIRROOT_ROOT)/include
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FAIRROOT_ROOT)/lib")
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
