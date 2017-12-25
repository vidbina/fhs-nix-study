{ stdenv, fetchurl, buildFHSUserEnv, makeWrapper, writeScriptBin, pkgs }:

let
  # helpers
  wrapBinary = libPaths: binaryName: ''
    echo "<---------------------";
    ls -la $out/bin/${binaryName};
    echo "<---------------------";
    wrapProgram "$out/bin/${binaryName}" \
      --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath libPaths}"
    echo "--------------------->";
    ls -la $out/bin/${binaryName};
    echo "--------------------->";
  '';
  fhsEnv = buildFHSUserEnv rec {
    name = "bitscope";
  };
  fhsEnvBin = "${fhsEnv}/bin/bitscope";
  fhsWrap = bin: writeScriptBin bin ''
    ${fhsEnvBin} $out/bin/${bin}
  '';

  mkBitscopeTool2 = args: pkgs.writeScriptBin args.name ''
    $!${stdenv.shell}
    ${fhsEnvBin} ${mkBitscopeTool args}
    # XXX ${mkBitscopeTool args}
  '';

  mkBitscopeTool = args: stdenv.mkDerivation (args // rec {
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
      echo "///////////////////////////"
      ls $out/bin
      ${builtins.concatStringsSep "\n" (map (wrapBinary libPaths) args.bins)}
      echo "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\"
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

  mkBitscope = args:
  let
    pkg = mkBitscopeTool args;
  in
    [
    (pkgs.writeScriptBin "bitscope-shoot" ''
      #!${stdenv.shell}
      ${fhsEnvBin} ${pkg}/bin/bitscope-dso
    '')
    ];

  bitscope-dso = mkBitscope rec {
    name = "${toolName}_${version}";
    toolName = "bitscope-dso";
    version = "2.8.FE22H";
    bins = [
      "bitscope-dso"
      "start-bitscope-dso"
    ];

    src =
      if stdenv.system == "x86_64-linux" then
        fetchurl {
          url = "http://bitscope.com/download/files/${name}_amd64.deb";
          sha256 = "0fc6crfkprj78dxxhvhbn1dx1db5chm0cpwlqpqv8sz6whp12mcj";
        }
      else if stdenv.system == "i686-linux" then
        fetchurl {
          url = "http://bitscope.com/download/files/${name}_i386.deb";
          sha256 = "0d338g21rzknwgn5wannvkyy9aq37vlfqkppgjv3bkjqkxcyvv7a";
        }
      else throw "no install instructions for ${stdenv.system}";
  };
#  mkBitscopeTool2 rec {
#    name = "${toolName}_${version}";
#    toolName = "bitscope-dso";
#    version = "2.8.FE22H";
#    bins = [
#      "bitscope-dso"
#      #"start-bitscope-dso"
#    ];
#
#    src =
#      if stdenv.system == "x86_64-linux" then
#        fetchurl {
#          url = "http://bitscope.com/download/files/${name}_amd64.deb";
#          sha256 = "0fc6crfkprj78dxxhvhbn1dx1db5chm0cpwlqpqv8sz6whp12mcj";
#        }
#      else if stdenv.system == "i686-linux" then
#        fetchurl {
#          url = "http://bitscope.com/download/files/${name}_i386.deb";
#          sha256 = "0d338g21rzknwgn5wannvkyy9aq37vlfqkppgjv3bkjqkxcyvv7a";
#        }
#      else throw "no install instructions for ${stdenv.system}";
#  };
#
#  bitscope-logic = (mkBitscopeTool rec {
#    name = "${toolName}_${version}";
#    toolName = "bitscope-logic";
#    version = "1.2.FC20C";
#
#    src =
#      if stdenv.system == "x86_64-linux" then
#        fetchurl {
#          url = "http://bitscope.com/download/files/${name}_amd64.deb";
#          sha256 = "0lkb7z9gfkiyxdwh4dq1zxfls8gzdw0na1vrrbgnxfg3klv4xns3";
#        }
#      else if stdenv.system == "i686-linux" then
#        fetchurl {
#          url = "http://bitscope.com/download/files/${name}_i386.deb";
#          sha256 = "092mn88rayfmih4lfhm1skdj8dz1nkcqi55r06lciawqjjjp0ip6";
#        }
#      else throw "no install instructions for ${stdenv.system}";
#  });
in stdenv.mkDerivation rec {
  name = "bitscope-sh";

  #study = bitscope-dso;
  #BITSCOPE_DSO="${bitscope-dso}";
  #BITSCOPE_LOGIC="${bitscope-logic}";

  #mk = mkBitscopeTool;
  #mk2 = mkBitscopeTool2;

  buildInputs = [
    bitscope-dso
  ];
#  buildInputs = [
#    (writeScriptBin "bitscope-dso" ''
#      ${fhsEnvBin} ${bitscope-dso}/bin/bitscope-dso
#    '')
##    (writeScriptBin "start-bitscope-dso" ''
##      ${fhsEnvBin} ${bitscope-dso}/bin/start-bitscope-dso
##    '')
#  ];

  shellHook = ''
    export PS1="\e[1;33m$ \e[0m";
    echo $out
  '';
}
