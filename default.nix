{ stdenv, fetchurl, dpkg }:

stdenv.mkDerivation rec {
  name = "bitscope-dso-dev";
  buildInputs = [
    (stdenv.mkDerivation rec {
      name = "bitscope-dso_${version}";
      version = "2.8.FE22H";
    
      src = fetchurl {
        url = "http://bitscope.com/download/files/bitscope-dso_2.8.FE22H_i386.deb";
        sha256 = "0d338g21rzknwgn5wannvkyy9aq37vlfqkppgjv3bkjqkxcyvv7a";
      };
    
      buildInputs = [ dpkg ];
    
      #phases = [ "unpackPhase" "buildPhase" "installPhase" ];
    
      unpackPhase = ''
        dpkg-deb -x ${src} ./
      '';
    
      dontBuild = true;
    
    #  buildPhase = ''
    #    touch rm-build
    #  '';
    
      installPhase = ''
        ls -la .
        mkdir -p "$out/bin"
        cp -a usr/* "$out/"
        echo "/////////////"
        ls -la $out
        #patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/bin/bitscope-dso"
        #patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/bin/start-bitscope-dso"
      '';
    })
  ];


  shellHook = ''
  '';
}
