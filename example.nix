{ pkgs ? import <nixpkgs> {} }: 

with pkgs;
buildFHSUserEnv {
  name = "example";

  targetPkgs = pkgs: [
    (pkgs.writeScriptBin "hello" ''
      #!${stdenv.shell}
      echo "Hi there"
    '')
  ];

  multiPkgs = pkgs: [
    (pkgs.writeScriptBin "oi" ''
      #!${stdenv.shell}
      echo "Oi!"
    '')
  ];
}
