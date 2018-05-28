package: FairSoft
version: v1.0
requires:
  - generators
  - simulation
  - ROOT
  - boost
  - protobuf
  - flatbuffers
  - msgpack
  - DDS
  - FairLogger
  - FairMQ
---
#!/bin/bash -e

# To add new dependencies it is sufficient to change the `requires:` field.
# Modulefile will update deps automatically.

MODULEFILE_REQUIRES=""
for PKG in $REQUIRES; do
  [[ $PKG != defaults* ]] || continue
  PKG_UP=$(echo $PKG|tr '[:lower:]' '[:upper:]'|tr '-' '_')
  MODULEFILE_REQUIRES="$MODULEFILE_REQUIRES $PKG/$(eval echo \$${PKG_UP}_VERSION-\$${PKG_UP}_REVISION)"
done
MODULEFILE_REQUIRES=$(echo $MODULEFILE_REQUIRES)

# Modulefile
MODULEDIR="$INSTALLROOT/etc/modulefiles"
MODULEFILE="$MODULEDIR/$PKGNAME"
mkdir -p "$MODULEDIR"
cat > "$MODULEFILE" <<EoF
#%Module1.0
proc ModulesHelp { } {
  global version
  puts stderr "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
}
set version $PKGVERSION-@@PKGREVISION@$PKGHASH@@
module-whatis "Modulefile for $PKGNAME $PKGVERSION-@@PKGREVISION@$PKGHASH@@"
# Dependencies
module load BASE/1.0 $MODULEFILE_REQUIRES
# Our environment
setenv FAIRSOFT_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
EoF