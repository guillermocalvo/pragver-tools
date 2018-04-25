#!/bin/bash

echo Installing Kcov...

set -x

# Install from source code
wget https://github.com/SimonKagstrom/kcov/archive/master.tar.gz
tar xzf master.tar.gz
cd kcov-master
mkdir build
cd build
cmake ..
make
sudo make install
cd ../..
rm -rf kcov-master

echo Installed `kcov --version`
