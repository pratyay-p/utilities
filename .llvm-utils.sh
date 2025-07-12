#!/bin/bash

function llvm_check_all_release() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    parallel_compile_job_num=$(nproc)
    parallel_link_job_num=$(expr $parallel_compile_job_num / 8)

    cmake --build $my_workspace_dir/build/Release \
        --parallel $parallel_compile_job_num

    cmake --build $my_workspace_dir/build/Release \
        --parallel $parallel_compile_job_num \
        --target check-all

    cd $original_dir
  }


function llvm_configure_release_x86() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    parallel_compile_job_num=$(nproc)
    parallel_link_job_num=$(expr $parallel_compile_job_num / 8)

    # Run the CMake command
    cmake -G 'Unix Makefiles' -B "$my_workspace_dir/build/Release" -S "$my_workspace_dir/llvm" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_INSTALL_PREFIX="$my_workspace_dir/install/Release" \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_PARALLEL_COMPILE_JOBS=$parallel_compile_job_num \
        -DLLVM_PARALLEL_LINK_JOBS=$parallel_link_job_num \
        -DLLVM_OPTIMIZED_TABLEGEN=TRUE
        #-DLLVM_ENABLE_RUNTIMES="libunwind;compiler-rt" 

    # go back to the original directory
    cd $original_dir

    # generate .clangd files
    echo -e "CompileFlags:\n  CompilationDatabase: $my_workspace_dir/build/Release/compile_commands.json" > .clangd
}

function clone_llvm_upstream_here() {
  local clone_name=${1:-llvm-cmplr}
  git clone https://github.com/pratyay-p/llvm-project.git $clone_name
  cd $clone_name
}

function llvm_configure_release_all() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    parallel_compile_job_num=$(nproc)
    parallel_link_job_num=$(expr $parallel_compile_job_num / 8)

    # Run the CMake command
    cmake -G 'Unix Makefiles' -B "$my_workspace_dir/build/Release" -S "$my_workspace_dir/llvm" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_INSTALL_PREFIX="$my_workspace_dir/install/Release" \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DLLVM_TARGETS_TO_BUILD="X86;NVPTX;PowerPC;AMDGPU;Hexagon" \
        -DLLVM_PARALLEL_COMPILE_JOBS=$parallel_compile_job_num \
        -DLLVM_PARALLEL_LINK_JOBS=$parallel_link_job_num \
        -DLLVM_OPTIMIZED_TABLEGEN=TRUE
        # -DLLVM_ENABLE_RUNTIMES="libunwind;compiler-rt"

    # go back to the original directory
    cd $original_dir

    # generate .clangd files
    echo -e "CompileFlags:\n  CompilationDatabase: $my_workspace_dir/build/Release/compile_commands.json" > .clangd
}

function llvm_configure_debug_x86() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    # Run the CMake command
    cmake -G 'Unix Makefiles' -B "$my_workspace_dir/build/Debug" -S "$my_workspace_dir/llvm" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DCMAKE_INSTALL_PREFIX="$my_workspace_dir/install/Debug" \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DBUILD_SHARED_LIBS=ON \
        -DLLVM_TARGETS_TO_BUILD="X86" \
        -DLLVM_PARALLEL_COMPILE_JOBS=$parallel_compile_job_num \
        -DLLVM_PARALLEL_LINK_JOBS=$parallel_link_job_num \
        -DLLVM_OPTIMIZED_TABLEGEN=TRUE
        # -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;compiler-rt"

    # go back to the original directory
    cd $original_dir

    # generate .clangd files
    echo -e "CompileFlags:\n  CompilationDatabase: $my_workspace_dir/build/Debug/compile_commands.json" > .clangd
}

function llvm_build_release() {
    # find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "error: could not find llvm-project root."
        return 1
    fi

    # verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "error: the detected git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    # run the compilation command
    cmake --build "$my_workspace_dir/build/Release" --parallel $(nproc)

    cd $original_dir
}

function llvm_build_debug() {
    # find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "error: could not find llvm-project root."
        return 1
    fi

    # verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "error: the detected git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    # run the compilation command
    cmake --build "$my_workspace_dir/build/Debug" --parallel $(nproc)

    cd $original_dir
}

function llvm_install_release() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    # Run the compilation command
    cmake --build "$my_workspace_dir/build/Release" --parallel $(nproc)

    # Install LLVM
    cmake --install $my_workspace_dir/build/Release

    cd $original_dir

}

function llvm_install_debug() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    # Run the compilation command
    cmake --build "$my_workspace_dir/build/Debug" --parallel $(nproc)

    # Install LLVM
    cmake --install $my_workspace_dir/build/Debug

    cd $original_dir

}

function llvm_local_install() {
    # Clone the repository
    git clone https://github.com/llvm/llvm-project.git llvm-src
    cd llvm-src
    git checkout llvmorg-20.1.7
    export my_workspace_dir="$(pwd)"

    # Run the CMake command for clang
    cmake -G 'Unix Makefiles' -B "$my_workspace_dir/build/Release" -S "$my_workspace_dir/llvm" \
        -DCMAKE_C_COMPILER=`which gcc` \
        -DCMAKE_CXX_COMPILER=`which g++` \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=OFF \
        -DCMAKE_INSTALL_PREFIX="/export/users/pratyayp/.local/llvm" \
        -DLLVM_ENABLE_PROJECTS="clang;lld;openmp;clang-tools-extra" \
        -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind;compiler-rt" \
        -DCMAKE_C_FLAGS="-O3 -mtune=sapphirerapids" \
        -DCMAKE_CXX_FLAGS="-O3 -mtune=sapphirerapids" \
        -DLLVM_ENABLE_ASSERTIONS=OFF \
        -DLLVM_BUILD_LLVM_DYLIB=ON \
        -DLLVM_TARGETS_TO_BUILD="AMDGPU;NVPTX;X86" \
        -DLLVM_INCLUDE_BENCHMARKS=0 \
        -DLLVM_INCLUDE_EXAMPLES=0 \
        -DLLVM_INCLUDE_TESTS=0 \
        -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON \
        -DCMAKE_INSTALL_RPATH="/export/users/pratyayp/.local/llvm/lib" \
        -DLLVM_ENABLE_OCAMLDOC=OFF \
        -DLLVM_ENABLE_BINDINGS=OFF \
        -DLLVM_TEMPORARILY_ALLOW_OLD_TOOLCHAIN=OFF \
        -DLLVM_PARALLEL_COMPILE_JOBS=$parallel_compile_job_num \
        -DLLVM_PARALLEL_LINK_JOBS=$parallel_link_job_num \
        -DLLVM_OPTIMIZED_TABLEGEN=TRUE \
        -DOPENMP_ENABLE_LIBOMPTARGET=OFF \
        -DLLVM_ENABLE_DUMP=OFF

    # run the compilation command
    cmake --build "$my_workspace_dir/build/Release" --parallel $(nproc)

    # Install LLVM
    cmake --install $my_workspace_dir/build/Release

    # go back to the original directory
    cd ..

    # remove the repository and build files
    rm -rf llvm-src

}

function llvm_setenv_debug() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    export PATH=$my_workspace_dir/build/Debug/bin:$PATH
    export LD_LIBRARY_PATH=$my_workspace_dir/build/Debug/lib:$PATH

    cd $original_dir

}

function llvm_setenv_release() {
    # Find the root of the llvm-project
    local dir="$(pwd)"
    local original_dir="$(pwd)"
    while [ ! -d "$dir/.git" ] && [ "$dir" != "/" ]; do
        dir=$(dirname "$dir")
    done

    if [ "$dir" == "/" ]; then
        echo "Error: Could not find llvm-project root."
        return 1
    fi

    # Verify that the repo is indeed llvm-project
    if ! git -C "$dir" remote -v | grep -q "/llvm-project.git"; then
        echo "Error: The detected Git repository is not llvm-project."
        return 1
    fi

    export my_workspace_dir="$dir"

    export PATH=$my_workspace_dir/build/Release/bin:$PATH
    export LD_LIBRARY_PATH=$my_workspace_dir/build/Release/lib:$PATH

    cd $original_dir

}

function llvm_local_intel_install() {
    wget https://github.com/intel/llvm/releases/download/v6.1.0/linux-sycl-6.1.0.tar.gz
    tar -xf linux-sycl-6.1.0.tar.gz


    git clone https://github.com/intel/llvm.git -b sycl intel-llvm
    export DPCPP_HOME="$(pwd)"
    cd intel-llvm
    git checkout v6.1.0
    python3 $DPCPP_HOME/intel-llvm/buildbot/configure.py \
        --shared-libs \
        -o $DPCPP_HOME/intel-llvm/build \
        -t "Release" \
        --cmake-gen "Ninja" \
        --cmake-opt "-DCMAKE_EXPORT_COMPILE_COMMANDS=OFF \
                     -DCMAKE_VERBOSE_MAKEFILE=ON \
                     -DCMAKE_INSTALL_PREFIX=\"/export/users/pratyayp/.local/llvm\" \
                     -DLLVM_ENABLE_RUNTIMES=\"libcxx;libcxxabi;libunwind;compiler-rt\" \
                     -DCMAKE_C_FLAGS=\"-O3 -mtune=sapphirerapids\" \
                     -DCMAKE_CXX_FLAGS=\"-O3 -mtune=sapphirerapids\" \
                     -DLLVM_OPTIMIZED_TABLEGEN=ON \
                     -DLLVM_USE_STATIC_ZSTD=OFF " \
        --llvm-external-projects "clang,lld,openmp,clang-tools-extra"
    python3 $DPCPP_HOME/intel-llvm/buildbot/compile.py -o $DPCPP_HOME/intel-llvm/build --build-parallelism $(nproc)
}

export llvm_install_release_x86
export llvm_configure_release_x86
export llvm_build_release_x86

export llvm_install_debug_x86
export llvm_configure_debug_x86
export llvm_build_debug_x86

export clone_llvm_upstream_here
export llvm_configure_release_all

export llvm_setenv_debug
export llvm_setenv_release
export llvm_local_intel_install



