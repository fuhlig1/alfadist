package: flatbuffers
version: "v1.3.0"
source: https://github.com/google/flatbuffers
tag: v1.3.0
build_requires:
  - CMake
---
#!/bin/sh

cmake -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
      -DCMAKE_CXX_COMPILER=$CXX \
      -DCMAKE_C_COMPILER=$CC \
      -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=$INSTALLROOT \
      "$SOURCEDIR"

make ${JOBS+-j $JOBS}
make install

#case $ARCHITECTURE in
#  osx*) 
#    cd $INSTALLROOT/lib
#    for file in $(ls *.dylib); do
#       install_name_tool -id ${WORK_DIR}/$PKGPATH/lib/$file $file
#    done
#    cd $INSTALLROOT/bin
#    declare -a _binaries=("nanocat")
#    for file in "${_binaries[@]}"; do
#        cd $INSTALLROOT/lib
#        for file1 in $(ls *.dylib); do
#          cd $INSTALLROOT/bin
#          install_name_tool -change $INSTALLROOT/lib/$file1 ${WORK_DIR}/$PKGPATH/lib/$file1 $file
#        done
#    done
#  ;;
#esac
