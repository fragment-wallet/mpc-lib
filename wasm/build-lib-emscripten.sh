#!/usr/bin/env bash

set -Cue -o pipefail

project_dir="$(cd "$(dirname "$(readlink "${0}" || echo "${0}")")/.." ; pwd)" # Absolute path to project dir
build_dir="${project_dir}/build/wasm"
obj_dir="${project_dir}/obj"
lib_dir="${project_dir}/lib"

mkdir -p "$build_dir" "$obj_dir" "$lib_dir"

build_c_targets() {
  (
    cd "$project_dir"

    echo "$(pwd)"

    while IFS= read -r target <&3 ; do
      echo "build ${target} output..."
      dir_name="$(dirname "$target")"
      noext_name="${target%.*}"

      mkdir -p "${obj_dir}/${dir_name}"

      # No debug: -O3 -DNDEBUG -UEDEBUG -UDEBUG
      emcc "$target" \
        -O2 -g -Wformat -Wformat-security \
        -m32 -fPIC -Wall -Wextra -Wvla -Wswitch-enum -Wno-missing-field-initializers -fdiagnostics-color=always \
        -shared -Wno-unknown-pragmas \
        -c \
        -I ./include \
        -I /openssl/include \
        -o "${obj_dir}/${noext_name}.o"

      # Left out flags:
      # -fstack-protector-strong

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
        -shared -Wno-unknown-pragmas \
        -std=c++17 -Wno-overloaded-virtual \
        -c \
        -I ./include \
        -I /openssl/include \
        -o "${obj_dir}/${noext_name}.o"

      # Left out flags:
      # -fstack-protector-strong

    done 3< <(find src/ -name "*.cpp" | sort)
  )
}

build_c_targets
build_cpp_targets
