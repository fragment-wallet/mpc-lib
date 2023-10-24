#!/usr/bin/env bash

set -Cue -o pipefail

project_dir="$(cd "$(dirname "$(readlink "${0}" || echo "${0}")")/.." ; pwd)" # Absolute path to project dir
build_dir="${project_dir}/build/wasm"
obj_dir="${project_dir}/obj"
lib_dir="${project_dir}/lib"

mkdir -p "$build_dir" "$obj_dir" "$lib_dir"

link_objects() {
  (
    cd "$project_dir"

    echo "build wasm binary..."

    llvm-ar rcs "${lib_dir}/mpc.a" `find "${obj_dir}" -type f -name *.o`

    # openssl libs are linked statically (-L, -lssl/crypto),
    # but the mpc archive lib is given as a compilation target, alongside the cpp  targets
    em++ wasm/wasm_wrappers.cpp \
      "${lib_dir}/mpc.a" \
      -sEXPORTED_FUNCTIONS="_malloc,_free,_sha256,_keccak1600,_ecdsa_keygen_1" \
      --no-entry \
      -O2 -m32 -fdiagnostics-color=always \
      -std=c++20 \
      -Wall \
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

link_objects
