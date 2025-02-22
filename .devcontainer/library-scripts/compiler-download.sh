#!/bin/bash

export XZ_OPT='-T0'

install_dir="$1"
shift
compilers_list="$1"
shift
bambuhls_compiler_url="https://release.bambuhls.eu/compiler"

inflate() {
   echo "Installing $1 into $2"
   case $1 in
      clang-12 )
         wget https://github.com/llvm/llvm-project/releases/download/llvmorg-12.0.1/clang+llvm-12.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-11 )
         wget https://github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/clang+llvm-11.1.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-10 )
         wget https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.1/clang+llvm-10.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-9 )
         wget https://github.com/llvm/llvm-project/releases/download/llvmorg-9.0.1/clang+llvm-9.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-8 )
         wget https://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-7 )
         wget https://releases.llvm.org/7.0.1/clang+llvm-7.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-6 )
         wget https://releases.llvm.org/6.0.1/clang+llvm-6.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-5 )
         wget https://releases.llvm.org/5.0.2/clang+llvm-5.0.2-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      clang-4 )
         wget https://releases.llvm.org/4.0.0/clang+llvm-4.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz -nv -O - | tar -C $2 -xJf - &
         ;;
      gcc-4.5 )
         wget ${bambuhls_compiler_url}/gcc-4.5-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-4.6 )
         wget ${bambuhls_compiler_url}/gcc-4.6-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-4.7 )
         wget ${bambuhls_compiler_url}/gcc-4.7-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-4.8 )
         wget ${bambuhls_compiler_url}/gcc-4.8-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-4.9 )
         wget ${bambuhls_compiler_url}/gcc-4.9-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-5 )
         wget ${bambuhls_compiler_url}/gcc-5-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-6 )
         wget ${bambuhls_compiler_url}/gcc-6-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-7 )
         wget ${bambuhls_compiler_url}/gcc-7-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      gcc-8 )
         wget ${bambuhls_compiler_url}/gcc-8-bambu-Ubuntu_16.04.tar.xz --no-check-certificate -nv -O - | tar -C $2 -xJf - 
         ;;
      * )
         ;;
   esac
} 
IFS=',' read -r -a compilers <<< "${compilers_list}"
compilers=( $(IFS=$'\n'; echo "${compilers[*]}" | sort -V) )
for compiler in "${compilers[@]}"
do
inflate $compiler $install_dir
done
wait
