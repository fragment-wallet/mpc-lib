#!/usr/bin/env bash

set -Cue -o pipefail

project_dir="$(cd "$(dirname "$(readlink "${0}" || echo "${0}")")" ; pwd)" # Absolute path to project dir
build_dir="${project_dir}/build/wasm"
obj_dir="${project_dir}/obj"
lib_dir="${project_dir}/lib"

mkdir -p "$build_dir" "$obj_dir" "$lib_dir"

build_c_targets() {
  (
    cd "$project_dir"

    while IFS= read -r target <&3 ; do
      echo "build ${target} output..."
      dir_name="$(dirname "$target")"
      noext_name="${target%.*}"

      mkdir -p "${obj_dir}/${dir_name}"

      # No debug: -O3 -DNDEBUG -UEDEBUG -UDEBUG
      emcc "$target" \
        -O2 -g -Wformat -Wformat-security \
        -m32 -fPIC -Wall -Wextra -Wvla -Wswitch-enum -Wno-missing-field-initializers -fdiagnostics-color=always \
        -shared -fstack-protector-strong -Wno-unknown-pragmas \
        -c \
        -I ./include \
        -I /openssl/include \
        -o "${obj_dir}/${noext_name}.o"

    done 3< <(find src/ -name "*.c" | sort)
  )
}

build_cpp_targets() {
  (
    cd "$project_dir"

    while IFS= read -r target <&3 ; do
      echo "build ${target} output..."
      dir_name="$(dirname "$target")"
      noext_name="${target%.*}"

      mkdir -p "${obj_dir}/${dir_name}"

      # No debug: -O3 -DNDEBUG -UEDEBUG -UDEBUG
      em++ "$target" \
        -O2 -g -Wformat -Wformat-security \
        -m32 -fPIC -Wall -Wextra -Wvla -Wswitch-enum -Wno-missing-field-initializers -fdiagnostics-color=always \
        -shared -fstack-protector-strong -Wno-unknown-pragmas \
        -std=c++17 -Wno-overloaded-virtual \
        -c \
        -I ./include \
        -I /openssl/include \
        -o "${obj_dir}/${noext_name}.o"

    done 3< <(find src/ -name "*.cpp" | sort)
  )
}

link_objects() {
  (
    cd "$project_dir"

    echo "build wasm binary..."

    llvm-ar rcs "${lib_dir}/mpc.a" `find "${obj_dir}" -type f -name *.o`

    # openssl libs are linked statically (-L, -lssl/crypto),
    # but the mpc archive lib is given as a compilation target, alongside the cpp  targets
    em++ src/wasm_wrappers.cpp \
      "${lib_dir}/mpc.a" \
      -sEXPORTED_FUNCTIONS="_sha256,_keccak1600,_malloc,_free" \
      --no-entry \
      -O2 -m32 \
      --std=c++17 \
      -lssl -lcrypto \
      -L /openssl/libs \
      -I /openssl/include \
      -I ./include \
      -o "${build_dir}/mpc.wasm"

    # Left out flags:
    # -fstack-protector-strong
    # -shared

    ls -lah "${build_dir}/mpc.wasm"
  )
}

"$@"
