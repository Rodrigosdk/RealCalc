#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if [[ "$(id -u)" -eq 0 ]]; then
  printf '%s\n' 'Não execute este script como root.' >&2
  exit 1
fi

for command_name in flutter cmake ninja gcc g++; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Comando ausente: %s\n' "$command_name" >&2
    exit 1
  fi
done

if ! printf 'int main() { return 0; }\n' | /usr/bin/g++ -x c++ -o /tmp/real_calc_gpp_test -; then
  printf '%s\n' 'O g++ não conseguiu compilar um programa C++ mínimo.' >&2
  exit 1
fi
rm -f /tmp/real_calc_gpp_test

export CC=/usr/bin/gcc
export CXX=/usr/bin/g++
unset CFLAGS CXXFLAGS LDFLAGS LIBRARY_PATH CPATH CMAKE_C_FLAGS CMAKE_CXX_FLAGS CMAKE_EXE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS

rm -rf "$PROJECT_ROOT/build/linux"
flutter pub get
flutter build linux

printf '\nBuild Linux concluído com sucesso.\n'
