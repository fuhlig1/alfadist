package: ROOT
version: "%(tag_basename)s"
source: https://github.com/root-mirror/root
tag: v6-06-04
requires:
  - AliEn-Runtime:(?!.*ppc64)
  - AlfaXRootD
  - GSL
  - pythia
  - opengl:(?!osx)
  - Xdevel:(?!osx)
  - FreeType:(?!osx)
build_requires:
  - CMake
env:
  ROOTSYS: "$ROOT_ROOT"
prepend_path:
  PYTHONPATH: "$ROOTSYS/lib"
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
  cd $INSTALLROOT/test
  env PATH=$INSTALLROOT/bin:$PATH LD_LIBRARY_PATH=$INSTALLROOT/lib:$LD_LIBRARY_PATH DYLD_LIBRARY_PATH=$INSTALLROOT/lib:$DYLD_LIBRARY_PATH make ${JOBS+-j$JOBS}
---
#!/bin/bash -e
unset ROOTSYS

VC="-Dvc=ON"

case $ARCHITECTURE in
  osx*) clang_version=$(clang --version | head -1 | cut -f 4 -d' ' | cut -f1,2 -d.)
        clang_major_version=$(echo $clang_version | cut -f1 -d.)
        if [ "$clang_version" = "7.3" -o $clang_major_version -ge 8 ]; then
          VC="-Dvc=OFF"
        fi
        ENABLE_COCOA=1
        [[ ! $GSL_ROOT ]] && GSL_ROOT=`brew --prefix gsl`
        [[ ! $OPENSSL_ROOT ]] && SYS_OPENSSL_ROOT=`brew --prefix openssl`
        ;;
esac

if [[ FAIRROOT ]]; then
  xrootd="-DXROOTD_ROOT_DIR=$ALFAXROOTD_ROOT" 
  freetype="-Dbuiltin-freetype=ON"
  pythia8="-DPYTHIA8_DIR=$PYTHIA_ROOT"
#  extraflags="-Dgdml=ON -Dxml=ON -Dbuiltin-ftgl=ON -Dbuiltin-glew=ON -Dasimage=ON -Drpath=ON -Dglobus=OFF $VC -DCMAKE_INSTALL_SYSCONFDIR=$INSTALLROOT/share/root/etc -Dgnuinstall=ON"
  extraflags="-Dgdml=ON -Dxml=ON -Dbuiltin-ftgl=ON -Dbuiltin-glew=ON -Dasimage=ON -Dglobus=OFF $VC"
else
  xrootd="${XROOTD_ROOT:+-DXROOTD_ROOT_DIR=$ALIEN_RUNTIME_ROOT}"
  freetype="-Dbuiltin-freetype=OFF"
  pythia8=""
  extraflags=" "
fi

[[ "$CXXFLAGS" != *'-std=c++11'* ]] || CXX11=1
[[ "$CXXFLAGS" != *"-stdlib=libc++"* ]] || LIBCXX=1

if [[ $ALICE_DAQ ]]; then
  # DAQ requires static ROOT, only supported by ./configure (not CMake).
  export ROOTSYS=$BUILDDIR
  $SOURCEDIR/configure                  \
    --with-pythia6-uscore=SINGLE        \
    --enable-minuit2                    \
    --enable-roofit                     \
    --enable-soversion                  \
    --enable-builtin-freetype           \
    --enable-builtin-pcre               \
    --enable-mathmore                   \
    --with-f77=gfortran                 \
    --with-cc=$COMPILER_CC              \
    --with-cxx=$COMPILER_CXX            \
    --with-ld=$COMPILER_LD              \
    ${CXXFLAGS:+--cxxflags="$CXXFLAGS"} \
    --disable-shadowpw                  \
    --disable-astiff                    \
    --disable-globus                    \
    --disable-krb5                      \
    --disable-ssl                       \
    --enable-mysql
  FEATURES="builtin_freetype builtin_pcre mathmore minuit2 pythia6 roofit
            soversion ${CXX11:+cxx11} mysql xml"
else
  # Normal ROOT build.
cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_C_COMPILER=$CC \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_Fortran_COMPILER=$FC \
      -DCMAKE_LINKER=$CXX \
      ${CXX11:+-Dcxx11=ON} \
      ${LIBCXX:+-Dlibcxx=ON} \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      ${ALIEN_RUNTIME_ROOT:+-Dalien=ON}                         \
      ${ALIEN_RUNTIME_ROOT:+-DALIEN_DIR=$ALIEN_RUNTIME_ROOT}    \
      ${ALIEN_RUNTIME_ROOT:+-DMONALISA_DIR=$ALIEN_RUNTIME_ROOT} \
      $xrootd \
      $pythia8 \
      -Dpcre=OFF                                                \
      -Dbuiltin_pcre=ON                                         \
      ${ENABLE_COCOA:+-Dcocoa=ON}                               \
      ${GSL_ROOT:+-DGSL_DIR=$GSL_ROOT}                          \
      ${OPENSSL_ROOT:+-DOPENSSL_ROOT=$ALIEN_RUNTIME_ROOT}       \
      ${SYS_OPENSSL_ROOT:+-DOPENSSL_ROOT=$SYS_OPENSSL_ROOT}     \
      ${SYS_OPENSSL_ROOT:+-DOPENSSL_INCLUDE_DIR=$SYS_OPENSSL_ROOT/include}  \
      ${LIBXML2_ROOT:+-DLIBXML2_ROOT=$ALIEN_RUNTIME_ROOT}       \
      -Dpgsql=OFF                                               \
      -Dminuit2=ON \
      -Dpythia6_nolink=ON                                       \
      -Droofit=ON                                               \
      -Dhttp=ON \
      -Dsoversion=ON \
      -Dshadowpw=OFF                                            \
      -Dvdt=ON                                                  \
      $extraflags \
      -DCMAKE_PREFIX_PATH="$FREETYPE_ROOT;$SYS_OPENSSL_ROOT;$GSL_ROOT;$ALIEN_RUNTIME_ROOT;$PYTHON_ROOT;$PYTHON_MODULES_ROOT" \
      $SOURCEDIR

  FEATURES="builtin_pcre mathmore xml ssl opengl minuit2
            pythia6 roofit soversion vdt ${CXX11:+cxx11} ${XROOTD_ROOT:+xrootd}
            ${ALIEN_RUNTIME_ROOT:+alien monalisa}
            ${ENABLE_COCOA:+builtin_freetype}"
  NO_FEATURES="${FREETYPE_ROOT:+builtin_freetype}"
fi

#case $ARCHITECTURE in
#  osx*)
#    sed -e "s#$INSTALLROOT#${WORK_DIR}/$PKGPATH#g" -i '' include/RConfigure.h
#    ;;
#     *)
#    sed -e "s#$INSTALLROOT#${WORK_DIR}/$PKGPATH#g" -i'' include/RConfigure.h
#    ;;
#esac


# Check if all required features are enabled
bin/root-config --features
for FEATURE in $FEATURES; do
  bin/root-config --has-$FEATURE | grep -q yes
done
for FEATURE in $NO_FEATURES; do
  bin/root-config --has-$FEATURE | grep -q no
done

if [[ $ALICE_DAQ ]]; then
  make ${JOBS+-j$JOBS}
  make static
  # *.o files from these modules need to be copied to the install directory
  # because AliRoot static build uses them directly
  for S in montecarlo/vmc tree/treeplayer io/xmlparser math/minuit2 sql/mysql; do
    mkdir -p $INSTALLROOT/$S/src
    cp -v $S/src/*.o $INSTALLROOT/$S/src/
  done
  export ROOTSYS=$INSTALLROOT
fi
make ${JOBS+-j$JOBS} install
[[ -d $INSTALLROOT/test ]] && ( cd $INSTALLROOT/test && env PATH=$INSTALLROOT/bin:$PATH LD_LIBRARY_PATH=$INSTALLROOT/lib:$LD_LIBRARY_PATH DYLD_LIBRARY_PATH=$INSTALLROOT/lib:$DYLD_LIBRARY_PATH make ${JOBS+-j$JOBS} )

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
                     ${GSL_VERSION:+GSL/$GSL_VERSION-$GSL_REVISION}                                             \\
                     ${FREETYPE_VERSION:+FreeType/$FREETYPE_VERSION-$FREETYPE_REVISION}                         \\
                     ${PYTHON_VERSION:+Python/$PYTHON_VERSION-$PYTHON_REVISION}                                 \\
                     ${PYTHON_MODULES_VERSION:+Python-modules/$PYTHON_MODULES_VERSION-$PYTHON_MODULES_REVISION}
# Our environment
setenv ROOT_RELEASE \$version
setenv ROOT_BASEDIR \$::env(BASEDIR)/$PKGNAME
setenv ROOTSYS \$::env(ROOT_BASEDIR)/\$::env(ROOT_RELEASE)
prepend-path PYTHONPATH \$::env(ROOTSYS)/lib
prepend-path PATH \$::env(ROOTSYS)/bin
prepend-path LD_LIBRARY_PATH \$::env(ROOTSYS)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(ROOTSYS)/lib")
EoF
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
