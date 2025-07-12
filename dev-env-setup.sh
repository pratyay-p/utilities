#!/bin/bash

echo Check the script and remove this line...
exit 1 
echo -------- Checking if GNU Make exists: $(which make 2>/dev/null || echo No... Bailing since further builds will fail.)
SB_DIR=/export/users/$USER
INSTALL_DIR=$SB_DIR/.local
LOG_DIR=$SB_DIR/.logs

mkdir -p $SB_DIR $INSTALL_DIR $LOG_DIR
cd $SB_DIR

# echo -------- Checking if clang exists: $(which clang 2>/dev/null || echo No... clang and lld will be installed.)
clang_location=$(which clang)
# echo -------- Checking if ninja exists: $(which ninja 2>/dev/null || echo No... ninja will be installed.)
ninja_location=$(which ninja)
# echo -------- Checking if clang exists: $(which nvim 2>/dev/null || echo No... neovim will be installed.)
nvim_location=$(which nvim)

# if [ ! -f "$clang_location" ]; then
	echo ---- Setting up clang ----

	echo -------- Cloning llvm ...
	rm -rf llvm-src
	git clone https://github.com/pratyay-p/llvm-project.git llvm-src 2>&1 > $LOG_DIR/clone-llvm.log
	cd llvm-src
	
	echo -------- Configuring LLVM. Projects: clang and lld. This will take almost 5 minutes...
	cmake -G 'Unix Makefiles' -B $PWD/build/Release -S $PWD/llvm \
		-DCMAKE_BUILD_TYPE=Release               \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON       \
		-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/llvm \
		-DLLVM_ENABLE_PROJECTS="clang;lld"       \
		-DLLVM_ENABLE_ASSERTIONS=ON              \
		-DBUILD_SHARED_LIBS=ON                   \
		-DLLVM_TARGETS_TO_BUILD="X86"            \
		-DLLVM_PARALLEL_COMPILE_JOBS=80          \
		-DLLVM_PARALLEL_LINK_JOBS=8              \
		-DLLVM_OPTIMIZED_TABLEGEN=TRUE           \
		2>&1 > $LOG_DIR/cmake-configure-llvm.log
	
	echo -------- Compiling LLVM: clang and lld. This will take almost 15-20 minutes...
	cmake --build $PWD/build/Release --parallel 160 2>&1 > $LOG_DIR/cmake-build-llvm.log
	
	echo -------- Installing LLVM...
	cmake --install $PWD/build/Release 2>&1 > $LOG_DIR/cmake-install-llvm.log
	
	cd $SB_DIR
	echo ---- Done installing clang

# elif [ ! -f "$ninja_location" ]; then
	echo ---- Setting up ninja

	echo -------- Cloning ninja source code ... 
	rm -rf ninja-src
	git clone https://github.com/ninja-build/ninja.git ninja-src 2>&1 > $LOG_DIR/clone-ninja.log
	cd ninja-src

	echo -------- Configuring ninja
	cmake -B $PWD/build                       \
		-DCMAKE_BUILD_TYPE=Release                \
		-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/ninja \
		2>&1 > $LOG_DIR/configure-ninja.log

	echo -------- Compiling ninja
	cmake --build $PWD/build --parallel 160 2>&1 > $LOG_DIR/compile-ninja.log

	echo -------- Installing ninja
	cmake --install $PWD/build

	echo -------- Ninja is installed. Re-trigger this script to update env and install others

	echo -------- Fetching gettext 0.24
	wget https://ftp.gnu.org/pub/gnu/gettext/gettext-0.24.tar.gz
	tar -xf gettext-0.24.tar.gz
	cd gettext-0.24
	CXXFLAGS="-O3 -mtune=icelake-server" CFLAGS="-O3 -mtune=icelake-server" \
				./configure --prefix=$INSTALL_DIR/gettext \
				--enable-shared \
				--enable-pic
	
	CXXFLAGS="-O3 -mtune=icelake-server" CFLAGS="-O3 -mtune=icelake-server" make install

# elif [ ! -f "$nvim_location" ]; then
	echo ---- Setting up neovim

	echo -------- Cloning neovim ...
	rm -rf nvim-src
	git clone https://github.com/pratyay-p/neovim.git nvim-src
	cd nvim-src

	echo -------- Configuring neovim
	CXXFLAGS="-O3 -mtune=icelake-server" \
		CFLAGS="-O3 -mtune=icelake-server" \
		make \
		CMAKE_EXTRA_FLAGS="-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/neovim" \
		2>&1 > $LOG_DIR/configure-neovim.log

	echo -------- Compiling neovim
	make install 2>&1 > $LOG_DIR/compile-neovim.log
# else
	echo ---- Nothing to Install
# fi
#

# Installation of liblz4
git clone https://github.com/lz4/lz4.git lz4-src
cd lz4-src
git checkout v1.10.0
make -j$(nproc) CC=clang CXX=clang++ CXXFLAGS="-O3 -mtune=sapphirerapids" CFLAGS="-O3 -mtune=sapphirerapids" PREFIX=/export/users/pratyayp/.local/lz4
make -j$(nproc) CC=clang CXX=clang++ CXXFLAGS="-O3 -mtune=sapphirerapids" CFLAGS="-O3 -mtune=sapphirerapids" PREFIX=/export/users/pratyayp/.local/lz4 install

# Installation of postgresql

  wget https://ftp.postgresql.org/pub/source/v17.5/postgresql-17.5.tar.gz
  tar -xf postgresql-17.5.tar.gz
  cd postgresql-17.5

  CC=clang CFLAGS="-O3 -mtune=sapphirerapids" CXX=clang++ CXXFLAGS="-O3 -mtune=sapphirerapids" ./configure --prefix=/export/users/pratyayp/.local/postgresql --with-llvm --without-readline --with-openssl --with-lz4

  make -j$(nproc) all
  make -j$(nproc) check 
  make -j$(nproc) install

  git clone https://github.com/timescale/timescaledb timescaledb-src
  cd timescaledb-src
  git checkout 2.20.3
   CC=clang CXX=clang CXXFLAGS="-O3 -mtune=sapphirerapids" CFLAGS="-O3 -mtune=sapphirerapids" ./bootstrap --install-prefix=/export/users/pratyayp/.local/timescaledb -G Ninja
   cmake --build ./build --parallel $(nproc)
   cmake --install ./build

# Installation of boost libraries
wget https://archives.boost.io/release/1.63.0/source/boost_1_63_0.tar.gz
tar -xf boost_1_63_0.tar.gz
cd boost_1_63_0/tools/build/
./bootstrap.sh
CC=clang CXX=clang++ CXXFLAGS="-O3 -mtune=sapphirerapids" CFLAGS="-O3 -mtune=sapphirerapids" ./b2 --prefix=/export/users/pratyayp/.local/boost-b2
export PATH="/export/users/pratyayp/.local/boost-b2/bin:$PATH"
cd ../..
CC=clang CXX=clang CXXFLAGS="-O3 -mtune=sapphirerapids" CFLAGS="-O3 -mtune=sapphirerapids" b2 --prefix=/export/users/pratyayp/.local/boost --build-dir=$PWD/builds
CC=clang CXX=clang CXXFLAGS="-O3 -mtune=sapphirerapids" CFLAGS="-O3 -mtune=sapphirerapids" b2 --prefix=/export/users/pratyayp/.local/boost --build-dir=$PWD/builds install

# Install AdaptiveCpp - DON'T
git clone https://github.com/AdaptiveCpp/AdaptiveCpp.git adaptivecpp-src
cd adaptivecpp-src
git checkout v25.02.0
cmake -G "Ninja" -B build \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_INSTALL_PREFIX="/export/users/pratyayp/.local/adaptivecpp" \
    -DBUILD_SHARED_LIBS=ON \
    -DUSE_EXTERNAL_LLVM=ON \
    -DLLVM_DIR="/export/users/pratyayp/.local/llvm/lib/cmake/llvm" \
    -DCLANG_DIR="/export/users/pratyayp/.local/llvm/bin/clang" \
    -DCLANG_INCLUDE_PATH="/export/users/pratyayp/.local/llvm/lib/clang/20/include" \
    -DBOOST_ROOT=$BOOST_ROOT

 cmake -G "Ninja" -B build 
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_INSTALL_PREFIX="/export/users/pratyayp/.local/adaptivecpp" \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_PREFIX_PATH="/export/users/pratyayp/.local/openmp" \
    -DOpenMP_C_FLAGS="-fopenmp -I/export/users/pratyayp/.local/openmp/include" \
    -DOpenMP_C_LIB_NAMES="omp" \
    -DOpenMP_omp_LIBRARY="/export/users/pratyayp/.local/openmp/lib/libomp.so" \
    -DOpenMP_CXX_FLAGS="-fopenmp -I/export/users/pratyayp/.local/openmp/include" \
    -DOpenMP_CXX_LIB_NAMES="omp" \
    -DOpenMP_omp_LIBRARY_RELEASE="/export/users/pratyayp/.local/openmp/lib/libomp.so" \
    -DBOOST_ROOT=$BOOST_ROOT

 cmake --build build --parallel -j$(nproc)
 cmake --install build

git clone https://github.com/facebook/zstd.git zstd-src
cd zstd-src/
git checkout v1.5.7
ls
cmake -B build -S build/cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX="/export/iusers/pratyayp/.local/zstd" -DCMAKE_C_FLAGS="-O3 -mtune=sapphirerapids" -DCMAKE_CXX_FLAGS="-O3 -mtune=sapphirerapids"
cmake --build build --parallel -j$(nproc)

