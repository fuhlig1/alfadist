package: defaults-fairsoft
version: v1
env:
  CXX: "clang++"
  CC: "clang"
  FC: "gfortran"
  CXXFLAGS: "-fPIC -g -O2 -std=c++11 -stdlib=libc++"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"
  FAIRROOT: "1"
disable:
  - AliEn-Runtime
  - AliRoot
  - lhapdf
overrides:
  boost:
    tag: "v1.61.0"
    source: "https://github.com/FairRootGroup/boost.git"
  pythia6:
    tag: "alice/416"  
  ROOT:
    version: "%(tag_basename)s"
    tag: "v6-06-04"
  CMake:
    tag: "v3.5.2"
    prefer_system_check: |
      which cmake && case `cmake --version | sed -e 's/.* //' | cut -d. -f1,2,3 | head -n1` in [0-2]*|3.[0-3].*|3.4.[0-2]) exit 1 ;; esac
---
# This file is included in any build recipe and it's only used to set
# environment variables. Which file to actually include can be defined by the
# "--defaults" option of alibuild.
