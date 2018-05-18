package: protobuf
version: "%(tag_basename)s"
tag: "v3.4.0"
source: https://github.com/google/protobuf
build_requires:
 - autotools
prefer_system: "(?!slc5)"
prefer_system_check: |
  printf "#include <google/protobuf/any.h>\n#if(GOOGLE_PROTOBUF_VERSION < 3004000)\n#error \"protobuf version >= 3.4.0 needed\"\n#endif\nint main(){}" | c++ -I$(brew --prefix protobuf)/include -Wno-deprecated-declarations -xc++ - -o /dev/null && which protoc &> /dev/null
---

rsync -av --delete --exclude="**/.git" $SOURCEDIR/ .
autoreconf -ivf

# Set the environment variables CC and CXX if a compiler is defined in the defaults file 
# In case CC and CXX are defined the corresponding compilers are used during compilation  
[[ -z "${_CXX_COMPILER}" ]] || export CXX=${_CXX_COMPILER}
[[ -z "${_C_COMPILER}" ]] || export CC=${_C_COMPILER}
[[ -z "${_CXX_FLAGS}" ]] || export CXXFLAGS="${_CXX_FLAGS}"
[[ -z "${_C_FLAGS}" ]] || export CFLAGS="${_C_FLAGS}"
[[ -z "${_CXX_STANDARD}" ]] || export CXXFLAGS="${_CXX_FLAGS} -std=c++${_CXX_STANDARD}"

./configure --prefix="$INSTALLROOT"
make ${JOBS:+-j $JOBS}
make install

#ModuleFile
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
setenv PROTOBUF_ROOT \$::env(BASEDIR)/$PKGNAME/\$version
prepend-path LD_LIBRARY_PATH \$::env(PROTOBUF_ROOT)/lib
$([[ ${ARCHITECTURE:0:3} == osx ]] && echo "prepend-path DYLD_LIBRARY_PATH \$::env(PROTOBUF_ROOT)/lib")
prepend-path PATH \$::env(PROTOBUF_ROOT)/bin
EoF
