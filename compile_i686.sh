# Extract
tar -xf ./binutils-2.43.tar.xz
tar -xf ./gcc-14.2.0.tar.xz

# Set environment variables
export PREFIX="$PWD/cross"
export PATH="$PREFIX/bin:$PATH"
export TARGET=i686-elf

# Build
mkdir -p ./cross

mkdir -p ./build-binutils && cd ./build-binutils
../binutils-2.43/configure \
 --target=$TARGET \
 --prefix="$PREFIX" \
 --with-sysroot \
 --disable-nls \
 --disable-werror

make
make install
echo Successfully built Binutils
cd ..

# Only uncomment this when gcc errors
# cd ./gcc-14.2.0 && ./contrib/download_prerequisites --verbose && cd ..

mkdir -p ./build-gcc && cd ./build-gcc
../gcc-14.2.0/configure \
 --target=$TARGET \
 --prefix="$PREFIX" \
 --enable-languages=c,c++,objc,obj-c++, rust \
 --disable-nls \
 --disable-werror \
 --without-headers

make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
echo Successfully built GCC-toolchain
cd ..

# Announce versions
i686-elf-as --version
i686-elf-gcc --version

# Clean up
rm -rf ./binutils-2.43
rm -rf ./gcc-14.2.0
rm -rf ./build-binutils
rm -rf ./build-gcc