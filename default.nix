{ stdenv, fetchurl, buildFHSUserEnv, makeWrapper, writeScriptBin, pkgs }:

let
  mkBitscopeTool = args: stdenv.mkDerivation (args // rec {
    name = "${args.toolName}_${args.version}";

    buildInputs = with args; [
      pkgs.dpkg
      makeWrapper
    ];

    unpackPhase = ''
      dpkg-deb -x ${args.src} ./
    '';

    dontBuild = true;

    installPhase = with args; ''
      mkdir -p "$out/bin"
      cp -a usr/* "$out/"
      wrapProgram $out/bin/bitscope-dso --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath libPaths}"
    '';

    libPaths = with args; with pkgs; [
      atk
      cairo
      gdk_pixbuf
      glib
      gtk2-x11
      pango
      xorg.libX11
    ];
  });
  tools = {
    dso = (mkBitscopeTool rec {
      toolName = "bitscope-dso";
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
    });
  };
  fhsEnv = buildFHSUserEnv rec {
    name = "bitscope";
  };
in stdenv.mkDerivation rec {
  name = "bitscope-sh";

  fhsEnvBin = "${fhsEnv}/bin/bitscope";

  buildInputs = [
    (writeScriptBin "bitscope-dso" ''
      ${fhsEnvBin} ${tools.dso}/bin/bitscope-dso
    '')
    (writeScriptBin "start-bitscope-dso" ''
      ${fhsEnvBin} ${tools.dso}/bin/start-bitscope-dso
    '')
  ];

  shellHook = ''
    export PS1="\e[1;33m$ \e[0m";
    echo $out
  '';
}
