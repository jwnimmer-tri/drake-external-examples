#!/bin/sh

set -ex

cd $(dirname "$0")
cd ..

rm -rf install && mkdir install

rm -rf tmp && mkdir tmp && cd tmp
tar xfz ~/Downloads/fmt-5.3.0.tgz
cmake fmt-5.3.0 -DCMAKE_INSTALL_PREFIX=../install -DFMT_TEST=OFF
make -j8 install
cd .. && rm -rf tmp

rm -rf tmp && mkdir tmp && cd tmp
cmake ../drake_custom_subset -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_PREFIX_PATH=../install
make
cd .. && rm -rf tmp
