{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { system = system; }
, gccUnwrapped ? pkgs.gcc15.cc
}:

let
  inherit (pkgs) lib;

  gccVersion = gccUnwrapped.version;

  gccPatched = pkgs.runCommand "gcc-${gccVersion}-pch"
    {
      outputs = [ "out" "lib" "libgcc" ];
    }
    ''
    set -euxo pipefail

    cp -r ${gccUnwrapped} $out
    cp -r ${gccUnwrapped.lib}    $lib
    cp -r ${gccUnwrapped.libgcc} $libgcc

    function gchgen {
      ${gccUnwrapped}/bin/g++ -x c++-header \
        -mtls-dialect=gnu2 -std="$3" -fno-stack-limit \
        -fdiagnostics-color=always -DONLINE_JUDGE \
        -c "$1" -o "$1.gch/$2.gch" $4 &
    }

    function ensureSingleCache {
      echo "Creating cache for $1"
      cd "$(dirname "$1")"
      local filename
      filename=$(basename "$1")
      chmod 755 .
      mkdir -p "$1.gch"
      gchgen "$filename" 98   c++98
      gchgen "$filename" 03   c++03
      gchgen "$filename" 11   c++11
      gchgen "$filename" 14   c++14
      gchgen "$filename" 17   c++17
      gchgen "$filename" 20   c++20
      gchgen "$filename" 23   c++23
      gchgen "$filename" 26   c++26
      wait
      gchgen "$filename" 98o2 c++98 -O2
      gchgen "$filename" 03o2 c++03 -O2
      gchgen "$filename" 11o2 c++11 -O2
      gchgen "$filename" 14o2 c++14 -O2
      gchgen "$filename" 17o2 c++17 -O2
      gchgen "$filename" 20o2 c++20 -O2
      gchgen "$filename" 23o2 c++23 -O2
      gchgen "$filename" 26o2 c++26 -O2
      wait
    }

    function ensureCache {
      local filename found
      filename=$(basename "$1")
      found=$(find "$out" -name "$filename" -print -quit)
      if [ -z "$found" ]; then
        echo "ERROR: '$1' not found under $out" >&2
        exit 1
      fi
      echo "Found: $found"
      ensureSingleCache "$found"
    }

    ensureCache bits/extc++.h
    ensureCache bits/stdc++.h
    ensureCache iostream
    ensureCache cstdio
    '';
in
pkgs.wrapCC gccPatched
