package: GEANT4
version: "%(tag_basename)s%(defaults_upper)s"
source: https://github.com/FairRootGroup/geant4
tag: v10.4.0-fairroot
build_requires:
  - CMake
incremental_recipe: |
  make ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
env:
  G4INSTALL : $GEANT4_ROOT
  G4DATASEARCHOPT : "-mindepth 2 -maxdepth 4 -type d -wholename"
  G4LEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4EMLOW*'`"
  G4LEVELGAMMADATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*PhotonEvaporation*'`"
  G4RADIOACTIVEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RadioactiveDecay*'`"
  G4NEUTRONHPDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NDL*'`"
  G4NEUTRONXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4NEUTRONXS*'`"
  G4SAIDXSDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT  '*data*G4SAIDDATA*'`"
  G4PIIDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4PII*'`"
  G4REALSURFACEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*RealSurface*'`"
  G4ENSDFSTATEDATA : "`find ${G4INSTALL} $G4DATASEARCHOPT '*data*G4ENSDFSTATE*'`"
---
#!/bin/bash -e

cmake                                                   \
  ${_C_COMPILER:+-DCMAKE_C_COMPILER=$_C_COMPILER}       \
  ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}              \
  ${_CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$_CXX_COMPILER} \
  ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}        \
  ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}       \
  -DCMAKE_INSTALL_PREFIX:PATH="$INSTALLROOT"            \
  -DCMAKE_INSTALL_LIBDIR="lib"                          \
  -DGEANT4_INSTALL_DATA_TIMEOUT=1500                    \
  -DGEANT4_BUILD_TLS_MODEL:STRING="global-dynamic"      \
  -DGEANT4_ENABLE_TESTING=OFF                           \
  -DBUILD_SHARED_LIBS=ON                                \
  -DGEANT4_INSTALL_EXAMPLES=OFF                         \
  -DGEANT4_BUILD_MULTITHREADED=OFF                      \
  -DGEANT4_USE_G3TOG4=ON                                \
  -DGEANT4_INSTALL_DATA=ON                              \
  -DGEANT4_USE_SYSTEM_EXPAT=OFF                         \
  -DGEANT4_USE_OPENGL_X11=ON                            \
  ${_CXX_STANDARD:+-DGEANT4_BUILD_CXXSTD=c++$_CXX_STANDARD}  \
  ${XERCESC_ROOT:+-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_USE_GDML=ON -DXERCESC_ROOT_DIR=$XERCESC_ROOT} \
  $SOURCEDIR

#  ${CXX14:+-DGEANT4_BUILD_CXXSTD=c++14}               \
#  ${CXX11:+-DGEANT4_BUILD_CXXSTD=c++11}               \
#  ${CXX98:+-DGEANT4_BUILD_CXXSTD=c++98}               \


cmake --build . --target install ${JOBS:+-- -j$JOBS} VERBOSE=1

# auto discovery of installation paths of G4 DATA
# in order to avoid putting hard-coded version numbers (which change with every G4 tag)
# these variables are used to create the modulefile below
G4DATASEARCHOPT="-mindepth 2 -maxdepth 4 -type d -wholename"
G4LEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*G4EMLOW*"`
G4LEVELGAMMADATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*PhotonEvaporation*"`
G4RADIOACTIVEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*RadioactiveDecay*"`
G4NEUTRONHPDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*G4NDL*"`
G4NEUTRONXSDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*G4NEUTRONXS*"`
G4SAIDXSDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*G4SAIDDATA*"`
G4PIIDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*G4PII*"`
G4REALSURFACEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*RealSurface*"`
G4ENSDFSTATEDATA=`find ${INSTALLROOT} $G4DATASEARCHOPT "*data*G4ENSDFSTATE*"`

ln -s lib $INSTALLROOT/lib64

#Get data file versions:
source $INSTALLROOT/bin/geant4.sh

G4LEVELGAMMADATA_NAME=$(basename "$G4LEVELGAMMADATA")
G4RADIOACTIVEDATA_NAME=$(basename "$G4RADIOACTIVEDATA")
G4LEDATA_NAME=$(basename "$G4LEDATA")
G4NEUTRONHPDATA_NAME=$(basename "$G4NEUTRONHPDATA")
G4NEUTRONXSDATA_NAME=$(basename "$G4NEUTRONXSDATA")
G4SAIDXSDATA_NAME=$(basename "$G4SAIDXSDATA")
G4NEUTRONXSDATA_NAME=$(basename "$G4NEUTRONXSDATA")
G4PIIDATA_NAME=$(basename "$G4PIIDATA")
G4REALSURFACEDATA_NAME=$(basename "$G4REALSURFACEDATA")
G4ENSDFSTATEDATA_NAME=$(basename "$G4ENSDFSTATEDATA")
G4ABLADATA_NAME=$(basename "$G4ABLADATA")
GEANT4_DATA_VERSION=$(dirname "$G4LEDATA")
GEANT4_DATA_VERSION=$(dirname "$GEANT4_DATA_VERSION")
GEANT4_DATA_VERSION=$(basename "$GEANT4_DATA_VERSION")

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
setenv G4INSTALL_DATA \$::env(G4INSTALL)/share/
setenv G4SYSTEM \$osname-g++
setenv G4LEVELGAMMADATA $G4LEVELGAMMADATA
setenv G4RADIOACTIVEDATA  $G4RADIOACTIVEDATA
setenv G4LEDATA $G4LEDATA
setenv G4NEUTRONHPDATA $G4NEUTRONHPDATA
setenv G4NEUTRONXSDATA $G4NEUTRONXSDATA
setenv G4SAIDXSDATA $G4SAIDXSDATA
setenv G4ENSDFSTATEDATA $G4ENSDFSTATEDATA
prepend-path PATH \$::env(GEANT4_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(GEANT4_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(GEANT4_ROOT)/lib")
EoF
