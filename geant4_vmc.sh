package: GEANT4_VMC
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v3-2-p1"
source: https://github.com/alisw/geant4_vmc
requires:
  - ROOT
  - GEANT4
  - vgm
build_requires:
  - CMake
env:
  G4VMCINSTALL: "$GEANT4_VMC_ROOT"
---
#!/bin/bash -e

#cmake "$SOURCEDIR"                             \
#  -DCMAKE_CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
#  -DGeant4VMC_USE_VGM=ON                       \
#  -DCMAKE_INSTALL_PREFIX="$INSTALLROOT"

cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      -DCMAKE_INSTALL_LIBDIR=lib                   \
      -DGeant4VMC_USE_VGM=ON \
      -DGeant4VMC_USE_GEANT4_UI=Off \
      -DGeant4VMC_USE_GEANT4_VIS=Off \
      -DGeant4VMC_USE_GEANT4_G3TOG4=On \
      -DCMAKE_SKIP_RPATH=TRUE \
      "$SOURCEDIR"

#      -DGeant4_DIR=$GEANT4_ROOT \
#      -DROOT_DIR=$ROOT_ROOT \
#      -DVGM_DIR=$VGM_ROOT/lib/VGM-4.3.0 \

make ${JOBS+-j $JOBS} install
G4VMC_SHARE=$(cd "$INSTALLROOT/share"; echo Geant4VMC-* | cut -d' ' -f1)
ln -nfs "$G4VMC_SHARE/examples" "$INSTALLROOT/share/examples"

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
module load BASE/1.0 ${GEANT4_VERSION:+GEANT4/$GEANT4_VERSION-$GEANT4_REVISION} ${ROOT_VERSION:+ROOT/$ROOT_VERSION-$ROOT_REVISION} vgm/$VGM_VERSION-$VGM_REVISION
# Our environment
setenv GEANT4_VMC_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4VMCINSTALL \$::env(GEANT4_VMC_ROOT)
prepend-path PATH \$::env(GEANT4_VMC_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(GEANT4_VMC_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GEANT4_VMC_ROOT)/lib")
EoF
