#!/bin/bash
GENERATOR="Unix Makefiles"

#sudo emerge -1v dev-cpp/gtest dev-cpp/gmock

#    -DUSE_SYSTEM_BOOST=ON \
#    -DUSE_SYSTEM_GMOCK=ON \
cmake -G "${GENERATOR}" \
    -DUSE_CLANG_COMPLETER=ON \
    -DUSE_SYSTEM_LIBCLANG=ON \
    . ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
