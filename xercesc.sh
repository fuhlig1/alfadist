package: xercesc
version: v3.2.1
tag: Xerces-C_3_2_1
source: https://github.com/apache/xerces-c
build_requires:
  - GCC-Toolchain:(?!osx)
  - ICU
---
#!/bin/bash -e

cmake  $SOURCEDIR                           \
       -DCMAKE_INSTALL_PREFIX=$INSTALLROOT

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
setenv XERCESC_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
setenv XERCESCROOT \$::env(XERCESC_ROOT)
setenv XERCESC_INST_DIR \$::env(XERCESC_ROOT)
setenv XERCESCINST \$::env(XERCESC_ROOT)
prepend-path PATH \$::env(XERCESC_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(XERCESC_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(XERCESC_ROOT)/lib")
EoF
