#!/bin/sh

set -ex
mydir=$(cd $(dirname "$0") && pwd)

deps="$mydir/deps"
rm -rf "$deps" && mkdir "$deps"

# Build eigen.
# wget http://bitbucket.org/eigen/eigen/get/3.3.3.tar.gz ~/Downloads/eigen-eigen-67e894c6cd8f.tar.gz
tar xfz ~/Downloads/eigen-eigen-67e894c6cd8f.tar.gz  # v3.3.3
mv eigen-eigen-67e894c6cd8f "$deps/eigen"

# Build ccd.
# wget https://github.com/danfis/libccd/archive/7931e764a19ef6b21b443376c699bbc9c6d4fba8.tar.gz -O ~/Downloads/libccd-7931e764a19ef6b21b443376c699bbc9c6d4fba8.tar.gz
rm -rf tmp && mkdir tmp && cd tmp
tar xfz ~/Downloads/libccd-7931e764a19ef6b21b443376c699bbc9c6d4fba8.tar.gz
cmake libccd-7931e764a19ef6b21b443376c699bbc9c6d4fba8 -DCMAKE_INSTALL_PREFIX="$deps/fcl"
make -j8 install
cd .. && rm -rf tmp

# Build fcl.
# wget https://github.com/flexible-collision-library/fcl/archive/2112037d3f0490f83c9e2d237886eb113b7b0d31.tar.gz -O ~/Downloads/fcl-2112037d3f0490f83c9e2d237886eb113b7b0d31.tar.gz
rm -rf tmp && mkdir tmp && cd tmp
tar xfz ~/Downloads/fcl-2112037d3f0490f83c9e2d237886eb113b7b0d31.tar.gz
cmake fcl-2112037d3f0490f83c9e2d237886eb113b7b0d31 -DCMAKE_INSTALL_PREFIX="$deps/fcl" -DBUILD_TESTING=OFF
make -j8 install
cd .. && rm -rf tmp

# Build fmt.
# wget https://github.com/fmtlib/fmt/archive/5.3.0.tar.gz -O ~/Downloads/fmt-5.3.0.tgz
rm -rf tmp && mkdir tmp && cd tmp
tar xfz ~/Downloads/fmt-5.3.0.tgz
cmake fmt-5.3.0 -DCMAKE_INSTALL_PREFIX="$deps/fmt" -DFMT_TEST=OFF
make -j8 install
cd .. && rm -rf tmp

# Build stx.
# wget https://github.com/tcbrindle/cpp17_headers/archive/4f82af87fd97969a89ed0018ae72e5dacc8d308a.tar.gz -O ~/Downloads/cpp17_headers-4f82af87fd97969a89ed0018ae72e5dacc8d308a.tar.gz
tar xfz  ~/Downloads/cpp17_headers-4f82af87fd97969a89ed0018ae72e5dacc8d308a.tar.gz
mv cpp17_headers-4f82af87fd97969a89ed0018ae72e5dacc8d308a "$deps/cpp17_headers"

# Build tinyobjloader.
# wget https://github.com/syoyo/tinyobjloader/archive/v1.0.6.tar.gz -O ~/Downloads/tinyobjloader-1.0.6.tar.gz
rm -rf tmp && mkdir tmp && cd tmp
tar xfz ~/Downloads/tinyobjloader-1.0.6.tar.gz
cmake tinyobjloader-1.0.6 -DCMAKE_INSTALL_PREFIX="$deps/tinyobjloader" -DCMAKE_CXX_FLAGS="-fPIC"
make -j8 install
cd .. && rm -rf tmp

# Stub spdlog.
mkdir "$deps/spdlog"

# Install a subset of drake as a library.
install="$mydir/../install"
rm -rf "$install" && mkdir "$install"
bazel run //:install -- "${install}"

(cd "$install" && find . -type d)
ldd "$install/lib/libdrake_custom_subset.so"
