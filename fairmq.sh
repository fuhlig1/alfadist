package: FairMQ
version: "%(tag_basename)s"
tag: v1.2.3
source: https://github.com/FairRootGroup/FairMQ
build_requires:
 - CMake
requires:
 - googletest
 - boost
 - FairLogger
 - ZeroMQ
 - nanomsg
 - msgpack
 - DDS
incremental_recipe: |
  cmake --build . --target install ${JOBS:+-- -j$JOBS}
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
mkdir -p $INSTALLROOT

cmake                                                            \
      ${_CXX_COMPILER:+-DCMAKE_CXX_COMPILER=$_CXX_COMPILER}      \
      ${_CXX_FLAGS:+-DCMAKE_CXX_FLAGS="$_CXX_FLAGS"}             \
      ${_CXX_STANDARD:+-DCMAKE_CXX_STANDARD=$_CXX_STANDARD}      \
      ${_CXX_STANDARD:+-DCMAKE_CXX_STANDARD_REQUIRED=YES}        \
      ${_CXX_STANDARD:+-DCMAKE_CXX_EXTENSIONS=NO}                \
      ${_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$_BUILD_TYPE}            \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                        \
      ${GOOGLETEST_ROOT:+-DGTEST_ROOT=$GOOGLETEST_ROOT}          \
      ${BOOST_ROOT:+-DBOOST_ROOT=$BOOST_ROOT}                    \
      ${FAIRLOGGER_ROOT:+-DFAIRLOGGER_ROOT=$FAIRLOGGER_ROOT}     \
      ${ZEROMQ_ROOT:+-DZEROMQ_ROOT=$ZEROMQ_ROOT}                 \
      ${NANOMSG_ROOT:+-DNANOMSG_ROOT=$NANOMSG_ROOT}              \
      ${MSGPACK_ROOT:+-DMSGPACK_ROOT=$MSGPACK_ROOT}              \
      ${DDS_ROOT:+-DDDS_ROOT=$DDS_ROOT}                          \
      -DDISABLE_COLOR=ON                                         \
      -DBUILD_DDS_PLUGIN=ON                                      \
      -DBUILD_NANOMSG_TRANSPORT=ON                               \
      -DCMAKE_INSTALL_LIBDIR=lib                                 \
      -DCMAKE_INSTALL_BINDIR=bin
      ${SOURCEDIR}

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
module load BASE/1.0                                                                    \\
            ${GOOGLETEST_VERSION:+googletest/$GOOGLETEST_VERSION-$GOOGLETEST_REVISION}  \\
            ${BOOST_VERSION:+boost/$BOOST_VERSION-$BOOST_REVISION}                      \\
            ${ZEROMQ_VERSION:+ZeroMQ/$ZEROMQ_VERSION-$ZEROMQ_REVISION}                  \\
            ${NANOMSG_VERSION:+nanomsg/$NANOMSG_VERSION-$NANOMSG_REVISION}              \\
            ${MSGPACK_VERSION:+msgpack/$MSGPACK_VERSION-$MSGPACK_REVISION}              \\
            ${DDS_VERSION:+DDS/$DDS_VERSION-$DDS_REVISION}
# Our environment
setenv FAIRMQ_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path PATH \$::env(FAIRMQ_ROOT)/bin
prepend-path LD_LIBRARY_PATH \$::env(FAIRMQ_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(FAIRMQ_ROOT)/lib")
EoF
MODULEDIR="$INSTALLROOT/etc/modulefiles"
mkdir -p $MODULEDIR && rsync -a --delete etc/modulefiles/ $MODULEDIR
