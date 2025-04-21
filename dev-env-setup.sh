#!/bin/bash

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
