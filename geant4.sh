package: GEANT4
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/alisw/geant4
tag: v4.10.01.p03
requires:
  - "GCC-Toolchain:(?!osx)"
build_requires:
  - CMake
  - CLHEP
env:
  G4INSTALL: "$GEANT4_ROOT"
  G4INSTALL_DATA: "$GEANT4_ROOT/share/Geant4-10.1.3"
  G4SYSTEM: "$(uname)-g++"
  G4LEVELGAMMADATA:         "$GEANT4_ROOT/share/Geant4-10.1.3/data/PhotonEvaporation3.1"
  G4RADIOACTIVEDATA:        "$GEANT4_ROOT/share/Geant4-10.1.3/data/RadioactiveDecay4.2"
  G4LEDATA:                 "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4EMLOW6.41"
  G4NEUTRONHPDATA:          "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4NDL4.5"
  G4NEUTRONXSDATA:          "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4NEUTRONXS1.4"
  G4SAIDXSDATA:             "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4SAIDDATA1.1"
  G4NeutronHPCrossSections: "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4NDL"
  G4PIIDATA:                "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4PII1.3"
  G4REALSURFACEDATA:        "$GEANT4_ROOT/share/Geant4-10.1.3/data/RealSurface1.0"
  G4ENSDFSTATEDATA:         "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4ENSDFSTATE1.0"
  G4ABLADATA:               "$GEANT4_ROOT/share/Geant4-10.1.3/data/G4ABLA3.0"
---
#!/bin/bash -e

if [[ $CXXFLAGS == *"-std=c++11"* ]]
then
  geant4_cpp="-DGEANT4_BUILD_CXXSTD=c++11"
else
  geant4_cpp=""
fi

if [[ FAIRROOT ]]; then
  geant4_multithreaded="-DGEANT4_BUILD_MULTITHREADED=ON"
else
  geant4_multithreaded="-DGEANT4_BUILD_MULTITHREADED=ON"
fi

cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_CXX_FLAGS="$CXXFLAGS -fPIC" \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT" \
      -DCMAKE_INSTALL_LIBDIR="lib" \
      -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic" \
      -DGEANT4_ENABLE_TESTING=OFF \
      -DBUILD_SHARED_LIBS=ON \
      -DGEANT4_INSTALL_EXAMPLES=OFF \
      -$geant4_multithreaded \
      -DCMAKE_STATIC_LIBRARY_C_FLAGS="-fPIC" \
      -DCMAKE_STATIC_LIBRARY_CXX_FLAGS="-fPIC" \
      -DGEANT4_USE_G3TOG4=ON \
      -DGEANT4_INSTALL_DATA=ON \
      -DGEANT4_INSTALL_DATA_TIMEOUT=1500 \
      -DGEANT4_USE_SYSTEM_EXPAT=OFF \
      $geant4_cpp \
      $SOURCEDIR

make ${JOBS+-j $JOBS}
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
module load BASE/1.0
# Our environment
set osname [uname sysname]
setenv GEANT4_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv G4INSTALL \$::env(GEANT4_ROOT)
setenv G4INSTALL_DATA \$::env(GEANT4_ROOT)/share/Geant4-10.1.3
setenv G4SYSTEM \$osname-g++
setenv G4LEVELGAMMADATA \$::env(G4INSTALL_DATA)/data/PhotonEvaporation3.1
setenv G4RADIOACTIVEDATA  \$::env(G4INSTALL_DATA)/data/RadioactiveDecay4.2
setenv G4LEDATA \$::env(G4INSTALL_DATA)/data/G4EMLOW6.41
setenv G4NEUTRONHPDATA \$::env(G4INSTALL_DATA)/data/G4NDL4.5
setenv G4NEUTRONXSDATA \$::env(G4INSTALL_DATA)/data/G4NEUTRONXS1.4
setenv G4SAIDXSDATA \$::env(G4INSTALL_DATA)/data/G4SAIDDATA1.1
setenv G4ABLADATA \$::env(G4INSTALL_DATA)/G4ABLA3.0
prepend-path PATH \$::env(GEANT4_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(GEANT4_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GEANT4_ROOT)/lib")
EoF
