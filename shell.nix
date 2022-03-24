{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  luaDeps = with luajitPackages; [ penlight ];
in
mkShell {
  nativeBuildInputs = [ gcc go nodejs gnumake ragel lemon bats ];
  buildInputs = [ ];
  propagatedBuildInputs = [ luajit ]
    ++ (with luajitPackages; [ busted luacheck ldoc ]);

  shellHook = with lib; ''
    export LUA_CPATH="${
      concatStringsSep ";" (map luajitPackages.getLuaCPath luaDeps)
    }"
    export LUA_PATH="./?.lua;$(pwd)/share/lua/5.1/?.lua;${
      concatStringsSep ";" (map luajitPackages.getLuaPath luaDeps)
    }"
    export LD_LIBRARY_PATH=$(readlink -f $(pwd)/share/c)

    [ -d share/c ] && make -s -C share/c
  '';
}
