package: defaults-fairroot-clang
version: v1
env:
  _CXX_COMPILER: "/cvmfs/it.gsi.de/compiler/llvm/6.0.1/bin/clang++"
  _C_COMPILER: "/cvmfs/it.gsi.de/compiler/llvm/6.0.1/bin/clang"
  _Fortran_COMPILER: ""
  _CXX_STANDARD: "11"
  _CXX_FLAGS: "-fPIC -stdlib=libc++"
  _C_FLAGS: "-fPIC"
  _Fortran_FLAGS: ""
  _BUILD_TYPE: "RELWITHDEBINFO"
---
