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

# extract the compilers

if [ -z "${_CXX_COMPILER}" ]; then
  case $ARCHITECTURE in
      osx*)
        CXX_COMPILER=$(which clang++)
        ;;
      *)
        CXX_COMPILER=$(which g++)
        ;;
  esac                                                                      
else
 export CXX_COMPILER=${_CXX_COMPILER}
fi

if [ -z "${_C_COMPILER}" ]; then
  case $ARCHITECTURE in
      osx*)
        C_COMPILER=$(which clang)
        ;;
      *)
        C_COMPILER=$(which gcc)
        ;;
  esac                                                                      
else
 export C_COMPILER=${_C_COMPILER}
fi

if [ -z "${_Fortran_COMPILER}" ]; then
  case $ARCHITECTURE in
      osx*)
        Fortran_COMPILER=$(which gfortran)
        ;;
      *)
        Fortran_COMPILER=$(which gfortran)
        ;;
  esac                                                                      
else
 export Fortran_COMPILER=${_Fortran_COMPILER}
fi

if [ -z "${_CXX_STANDARD}" ]; then
  _compileflags="${_CXX_FLAGS}"
else
  _compileflags="${_CXX_FLAGS} -std=c++${_CXX_STANDARD}"
fi

# fairsoft-config
mkdir -p bin
cat > bin/fairsoft-config <<EoF
#!/bin/bash

_version=may18
_cc=${C_COMPILER}
_cxx=${CXX_COMPILER}
_f77=${Fortran_COMPILER}
_cxxflags="${_compileflags}"
_root_version=6
_base_cxxflags="${_compileflags}"

usage="\
Usage: fairsoft-config [--version] [--cc] [--cxx] [--f77] \
 [--cxxflags] [--root-version] [--help]"

if [ \$# -eq 0 -o \$# -gt 1 ]; then
   echo "\${usage}" 1>&2
   exit 1
fi

out=""


case \$1 in
    --version)
      ### Output the fairsoft version
      out="\$out \${_version}"
      ;;
    --cc)
      ### Output the full path of used c compiler
      out="\$out \${_cc}"
      ;;
    --cxx)
      ### Output the full path of used cxx compiler
      out="\$out \${_cxx}"
      ;;
    --cxxflags)
      ### Output the used special cxx compiler flags
      out="\$out \${_cxxflags}"
      ;;
    --f77)
      ### Output the full path of used fortran compiler
      out="\$out \${_f77}"
      ;;
    --root-version)
      ### Output the major version of root
      out="\$out \${_root_version}"
      ;;
    --help)
      ### Print a help message
      echo "Usage: `basename $0` [options]"
      echo ""
      echo "  --version            Print the fairsoft version"
      echo "  --cc                 Print the full path of the used c compiler"
      echo "  --cxx                Print the full path of the used cxx compiler"
      echo "  --f77                Print the full path of the used fortran compiler"
      echo "  --cxxflags           Print the used special cxx compiler flags"
      echo "  --root-version       Print the major version of ROOT (5 or 6)"
      exit 0
      ;;
    *)
      ### Give an error
      echo "Unknown argument \"\$1\"!" 1>&2
      echo "\${usage}" 1>&2
      exit 1
      ;;
esac

### Output the stuff
echo \$out
EoF
chmod a+x bin/fairsoft-config
BINDIR="$INSTALLROOT/bin"
mkdir -p $BINDIR && rsync -a --delete bin/ $BINDIR


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
