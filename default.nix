{ stdenv, pkgs }:

stdenv.mkDerivation rec {
  name = "bitscope";
  src = ./.;
  version = "0.1.0";

  buildInputs = with pkgs; [
  ];

  #shellHook = ''
  #''

}
