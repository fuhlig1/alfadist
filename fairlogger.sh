package: FairLogger
version: "%(tag_basename)s"
tag: v1.2.0
source: https://github.com/FairRootGroup/FairLogger
build_requires:
 - CMake
incremental_recipe: |
  cmake --build . --target install ${JOBS:+-- -j$JOBS}
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
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
      -DCMAKE_INSTALL_LIBDIR=lib                            \
      -DDISABLE_COLOR=ON                                    \
      $SOURCEDIR

cmake --build . ${JOBS:+-- -j$JOBS} VERBOSE=1
ctest ${JOBS:+-j$JOBS}
cmake --build . --target install

#ModuleFile
mkdir -p etc/modulefiles
cat > etc/modulefiles/$PKGNAME <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0
# Our environment
setenv FAIRLOGGER_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(FAIRLOGGER_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FAIRLOGGER_ROOT)/lib")
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
