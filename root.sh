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

[[ "$CXXFLAGS" == *'-std=c++11'* ]] && CXX11=1 || true
[[ "$CXXFLAGS" == *'-std=c++14'* ]] && CXX14=1 || true

if [ -z "$CXX_COMPILER" -a -z "$C_COMPILER" ]; then
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
  COMPILER_CC=$C_COMPILER
  COMPILER_CXX=$CXX_COMPILER
  COMPILER_LD=$CXX_COMPILER
  case $ARCHITECTURE in
    osx*)
      ENABLE_COCOA=1
      [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
      [[ ! $OPENSSL_ROOT ]] && SYS_OPENSSL_ROOT=`brew --prefix openssl`
      ;;
  esac
fi


  # Normal ROOT build.
cmake $SOURCEDIR                                                \
  -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE                      \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                       \
  ${ALIEN_RUNTIME_ROOT:+-Dalien=ON}                         \
  ${ALIEN_RUNTIME_ROOT:+-DALIEN_DIR=$ALIEN_RUNTIME_ROOT}    \
  ${ALIEN_RUNTIME_ROOT:+-DMONALISA_DIR=$ALIEN_RUNTIME_ROOT} \
  ${XROOTD_ROOT:+-DXROOTD_ROOT_DIR=$ALIEN_RUNTIME_ROOT}     \
  ${CXX11:+-Dcxx11=ON}                                      \
  ${CXX14:+-Dcxx14=ON}                                      \
  -Dfreetype=ON                                             \
  -Dbuiltin_freetype=OFF                                    \
  -Dpcre=OFF                                                \
  -Dbuiltin_pcre=ON                                         \
  ${ENABLE_COCOA:+-Dcocoa=ON}                               \
  -DCMAKE_CXX_COMPILER=$COMPILER_CXX                        \
  -DCMAKE_C_COMPILER=$COMPILER_CC                           \
  -DCMAKE_LINKER=$COMPILER_LD                               \
  ${Fortran_COMPILER:+-DCMAKE_Fortran_COMPILER=$Fortran_COMPILER} \
  ${GCC_TOOLCHAIN_VERSION:+-DCMAKE_EXE_LINKER_FLAGS="-L$GCC_TOOLCHAIN_ROOT/lib64"} \
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
  -DCMAKE_PREFIX_PATH="$FREETYPE_ROOT;$SYS_OPENSSL_ROOT;$GSL_ROOT;$ALIEN_RUNTIME_ROOT"
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

make ${JOBS+-j$JOBS} install

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
