package: ROOT
version: "%(tag_basename)s%(defaults_upper)s"
tag: "v6-12-06"
source: https://github.com/root-mirror/root
requires:
  - gsl
  - opengl:(?!osx)
  - Xdevel:(?!osx)
  - FreeType:(?!osx)
build_requires:
  - CMake
env:
  ROOTSYS: "$ROOT_ROOT"
incremental_recipe: |
  if [[ $ALICE_DAQ ]]; then
    export ROOTSYS=$BUILDDIR && make ${JOBS+-j$JOBS} && make static
    for S in montecarlo/vmc tree/treeplayer io/xmlparser math/minuit2 sql/mysql; do
      mkdir -p $INSTALLROOT/$S/src
      cp -v $S/src/*.o $INSTALLROOT/$S/src/
    done
    export ROOTSYS=$INSTALLROOT
  fi
  make ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -e
unset ROOTSYS

[[ "$_CXX_STANDARD" == "11" ]] && CXX11=1 || true
[[ "$_CXX_STANDARD" == "14" ]] && CXX14=1 || true

if [ -z "$_CXX_COMPILER" -a -z "$_C_COMPILER" ]; then
  case $ARCHITECTURE in
    osx*)
      ENABLE_COCOA=1
      COMPILER_CC=clang
      COMPILER_CXX=clang++
      COMPILER_LD=clang
      [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
      [[ ! $OPENSSL_ROOT ]] && SYS_OPENSSL_ROOT=`brew --prefix openssl`
      ;;
    *)
      COMPILER_CC=cc
      COMPILER_CXX=c++
      COMPILER_LD=c++
    ;;
  esac
else
  COMPILER_CC=${_C_COMPILER}
  COMPILER_CXX=${_CXX_COMPILER}
  COMPILER_LD=${_CXX_COMPILER}
  case $ARCHITECTURE in
    osx*)
      ENABLE_COCOA=1
      [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
      [[ ! $OPENSSL_ROOT ]] && SYS_OPENSSL_ROOT=`brew --prefix openssl`
      ;;
  esac
fi

  # Normal ROOT build.
cmake                                                       \
  -DCMAKE_CXX_COMPILER=$COMPILER_CXX                        \
  -DCMAKE_C_COMPILER=$COMPILER_CC                           \
  -DCMAKE_LINKER=$COMPILER_LD                               \
  ${_Fortran_COMPILER:+-DCMAKE_Fortran_COMPILER=$_Fortran_COMPILER} \
  ${_C_FLAGS:+-DCMAKE_C_FLAGS="$_C_FLAGS"}              \
  ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}        \
  ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}       \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                       \
  ${XROOTD_ROOT:+-DXROOTD_ROOT_DIR=$ALIEN_RUNTIME_ROOT}     \
  ${CXX11:+-Dcxx11=ON}                                      \
  ${CXX14:+-Dcxx14=ON}                                      \
  -Dfreetype=ON                                             \
  -Dbuiltin_freetype=OFF                                    \
  -Dpcre=OFF                                                \
  -Dbuiltin_pcre=ON                                         \
  ${ENABLE_COCOA:+-Dcocoa=ON}                               \
  ${OPENSSL_ROOT:+-DOPENSSL_ROOT=$ALIEN_RUNTIME_ROOT}       \
  ${SYS_OPENSSL_ROOT:+-DOPENSSL_ROOT=$SYS_OPENSSL_ROOT}     \
  ${SYS_OPENSSL_ROOT:+-DOPENSSL_INCLUDE_DIR=$SYS_OPENSSL_ROOT/include}  \
  ${LIBXML2_ROOT:+-DLIBXML2_ROOT=$ALIEN_RUNTIME_ROOT}       \
  ${GSL_ROOT:+-DGSL_DIR=$GSL_ROOT}                          \
  -Dpgsql=OFF                                               \
  -Dminuit2=ON                                              \
  -Dpythia6_nolink=ON                                       \
  -Droofit=ON                                               \
  -Dhttp=ON                                                 \
  -Dsoversion=ON                                            \
  -Dshadowpw=OFF                                            \
  -Dvdt=ON                                                  \
  -Dbuiltin_vdt=ON                                          \
  -DCMAKE_PREFIX_PATH="$FREETYPE_ROOT;$SYS_OPENSSL_ROOT;$GSL_ROOT;$ALIEN_RUNTIME_ROOT" \
  $SOURCEDIR
  
FEATURES="builtin_pcre mathmore xml ssl opengl minuit2 http
      pythia6 roofit soversion vdt ${CXX11:+cxx11} ${CXX14:+cxx14} ${XROOTD_ROOT:+xrootd}
      ${ALIEN_RUNTIME_ROOT:+alien monalisa}
      ${ENABLE_COCOA:+builtin_freetype}"
NO_FEATURES="${FREETYPE_ROOT:+builtin_freetype}"
# Check if all required features are enabled
bin/root-config --features
for FEATURE in $FEATURES; do
  bin/root-config --has-$FEATURE | grep -q yes
done
for FEATURE in $NO_FEATURES; do
  bin/root-config --has-$FEATURE | grep -q no
done

make ${JOBS+-j$JOBS} install VERBOSE=1

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
module load BASE/1.0 ${ALIEN_RUNTIME_ROOT:+AliEn-Runtime/$ALIEN_RUNTIME_VERSION-$ALIEN_RUNTIME_REVISION}        \\
                     ${GCC_TOOLCHAIN_VERSION:+GCC-Toolchain/$GCC_TOOLCHAIN_VERSION-$GCC_TOOLCHAIN_REVISION}     \\
                     ${GSL_VERSION:+GSL/$GSL_VERSION-$GSL_REVISION}                                             \\
                     ${FREETYPE_VERSION:+FreeType/$FREETYPE_VERSION-$FREETYPE_REVISION}

# Our environment
setenv ROOT_RELEASE \$version
setenv ROOT_BASEDIR \$::env(BASEDIR)/$PKGNAME
setenv ROOTSYS \$::env(ROOT_BASEDIR)/\$::env(ROOT_RELEASE)
prepend-path PATH \$::env(ROOTSYS)/bin
prepend-path LD_LIBRARY_PATH \$::env(ROOTSYS)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ROOTSYS)/lib")
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
