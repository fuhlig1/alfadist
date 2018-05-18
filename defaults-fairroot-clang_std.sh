package: defaults-fairroot-clang_std
version: v1
env:
  _CXX_COMPILER: "/cvmfs/it.gsi.de/compiler/llvm/6.0.1/bin/clang++"
  _C_COMPILER: "/cvmfs/it.gsi.de/compiler/llvm/6.0.1/bin/clang"
  _Fortran_COMPILER: ""
  _CXX_STANDARD: "11"
  _CXX_FLAGS: "-fPIC -stdlib=libstdc++"
  _C_FLAGS: "-fPIC"
  _Fortran_FLAGS: ""
  _BUILD_TYPE: "RELWITHDEBINFO"
---

#  CPLUS_INCLUDE_PATH: "/cvmfs/it.gsi.de/compiler/gcc/6.3.0/include/c++/6.3.0/"
