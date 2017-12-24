{ stdenv, fetchurl, dpkg, buildFHSUserEnv, makeWrapper, gdk_pixbuf, libX11, writeScriptBin }:

let
  tools = {
    dso = (stdenv.mkDerivation rec {
      name = "bitscope-dso_${version}";
      version = "2.8.FE22H";

      src =
        if stdenv.system == "x86_64-linux" then
          fetchurl {
            url = "http://bitscope.com/download/files/bitscope-dso_2.8.FE22H_amd64.deb";
            sha256 = "0fc6crfkprj78dxxhvhbn1dx1db5chm0cpwlqpqv8sz6whp12mcj";
          }
        else if stdenv.system == "i686-linux" then
          fetchurl {
            url = "http://bitscope.com/download/files/bitscope-dso_2.8.FE22H_i386.deb";
            sha256 = "0d338g21rzknwgn5wannvkyy9aq37vlfqkppgjv3bkjqkxcyvv7a";
          }
        else throw "no install instructions for ${stdenv.system}";

        buildInputs = [
          dpkg
          makeWrapper
        ];

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
        wrapProgram $out/bin/bitscope-dso --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath [
          libX11
          gdk_pixbuf
        ]}"
      '';

      postInstall = ''
      '';
    });
  };
  fhsEnv = buildFHSUserEnv rec {
    name = "bitscope";
  };
in stdenv.mkDerivation rec {
  name = "bitscope-sh";

  #inherit tools;

  buildInputs = [
    (writeScriptBin "bitscope-dso" ''
      ${fhsEnv}/bin/bitscope ${tools.dso}/bin/bitscope-dso
    '')
    (writeScriptBin "start-bitscope-dso" ''
      ${fhsEnv}/bin/bitscope ${tools.dso}/bin/start-bitscope-dso
    '')
  ];

  shellHook = ''
    export PS1="\e[1;33m$ \e[0m";
    echo $out
  '';
}
