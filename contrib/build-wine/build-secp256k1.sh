#!/bin/bash
# heavily based on https://github.com/ofek/coincurve/blob/417e726f553460f88d7edfa5dc67bfda397c4e4a/.travis/build_windows_wheels.sh

set -e

build_dll() {
    #sudo apt-get install -y mingw-w64
    export SOURCE_DATE_EPOCH=1530212462
    ./autogen.sh
    echo "LDFLAGS = -no-undefined" >> Makefile.am
    LDFLAGS="-Wl,--no-insert-timestamp" ./configure \
        --host=$1 \
        --enable-module-recovery \
        --enable-experimental \
        --enable-module-ecdh \
        --disable-jni
    make
    ${1}-strip .libs/libsecp256k1-0.dll
}


cd /tmp/electrum-rvn-build

if [ ! -d secp256k1 ]; then
    git clone https://github.com/bitcoin-core/secp256k1.git
    cd secp256k1;
else
    cd secp256k1
    git pull
fi

LIBSECP_VERSION="b408c6a8b287003d1ade5709e6f7bc3c7f1d5be7"
git reset --hard "$LIBSECP_VERSION"
git clean -f -x -q

build_dll i686-w64-mingw32  # 64-bit would be: x86_64-w64-mingw32
mv .libs/libsecp256k1-0.dll libsecp256k1.dll

find -exec touch -d '2000-11-11T11:11:11+00:00' {} +

echo "building libsecp256k1 finished"
