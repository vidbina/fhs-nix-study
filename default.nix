{ stdenv, fetchurl, buildFHSUserEnv, makeWrapper, pkgs }:

# See https://trello.com/b/5ZqfmGUD/bitscope-%E2%9A%9D-software for more info
let
  wrapBinary = libPaths: binaryName: ''
    wrapProgram "$out/bin/${binaryName}" \
      --prefix LD_LIBRARY_PATH : "${stdenv.lib.makeLibraryPath libPaths}"
  '';

  mkBitscope = attrs: let
    mkBitscopeTool = overrides: stdenv.mkDerivation (rec {
      meta = {
        homepage = http://bitscope.com/software/;
        license = stdenv.lib.licenses.unfree;
        platforms = [ "i686-linux" "x86_64-linux" ];
        maintainers = with stdenv.lib.maintainers; [
          "David Asabina <vid@bina.me>"
        ];
      };

      buildInputs = with pkgs; [
        dpkg
        makeWrapper
      ];

      libs = with pkgs; [
        atk
        cairo
        gdk_pixbuf
        glib
        gtk2-x11
        pango
        xorg.libX11
      ];

      dontBuild = true;

      unpackPhase = ''
        dpkg-deb -x ${overrides.src} ./
      '';

      # installPhase expects bins to be defined in the overrides set
      # bins is a list of package binary names which need to be wrapped
      installPhase = ''
        mkdir -p "$out/bin"
        cp -a usr/* "$out/"
        ${builtins.concatStringsSep "\n" (map (wrapBinary libs) overrides.bins)}
      '';
    } // overrides);
    pkg = mkBitscopeTool attrs;
  in buildFHSUserEnv {
    name = attrs.toolName;
    meta = pkg.meta;
    runScript = "${pkg.outPath}/bin/${attrs.toolName}";
  };

  bitscope-dso = let
    name = "${toolName}_${version}";
    toolName = "bitscope-dso";
    version = "2.8.FE22H";
  in mkBitscope {
    inherit name toolName version;

    meta = {
      description = "Test and measurement software for BitScope";
      homepage = "http://bitscope.com/software/dso/";
    };

    bins = [
      "bitscope-dso" # "start-bitscope-dso"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "0fc6crfkprj78dxxhvhbn1dx1db5chm0cpwlqpqv8sz6whp12mcj";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "0d338g21rzknwgn5wannvkyy9aq37vlfqkppgjv3bkjqkxcyvv7a";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-logic = let
    name = "${toolName}_${version}";
    toolName = "bitscope-logic";
    version = "1.2.FC20C";
  in mkBitscope {
    inherit name toolName version;

    meta = {
      description = "Mixed signal logic timing and serial protocol analysis software for BitScope";
      home = "http://bitscope.com/software/logic/";
    };

    bins = [
      "bitscope-logic" # "start-bitscope-logic"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "0lkb7z9gfkiyxdwh4dq1zxfls8gzdw0na1vrrbgnxfg3klv4xns3";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "092mn88rayfmih4lfhm1skdj8dz1nkcqi55r06lciawqjjjp0ip6";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-meter = let
    name = "${toolName}_${version}";
    toolName = "bitscope-meter";
    version = "2.0.FK22G";
  in mkBitscope {
    inherit name toolName version;

    meta = {
      description = "Automated oscilloscope, voltmeter and frequency meter for BitScope";
      homepage = "http://bitscope.com/software/logic/";
    };

    bins = [
      "bitscope-meter" # "start-bitscope-meter"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "0nirbci6ymhk4h4bck2s4wbsl5r9yndk2jvvv72zwkg21248mnbp";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "0y9s7p36v7agqhi076711ds22nfxqmfgq13r01m57lpn9xfz5fja";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-chart = let
    name = "${toolName}_${version}";
    toolName = "bitscope-chart";
    version = "2.0.FK22M";
  in mkBitscope {
    inherit name toolName version;

    meta = {
      description = "Multi-channel waveform data acquisition and chart recording application";
      homepage = "http://bitscope.com/software/chart/";
    };

    bins = [
      "bitscope-chart" # "start-bitscope-chart"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "08mc82pjamyyyhh15sagsv0sc7yx5v5n54bg60fpj7v41wdwrzxw";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "08p6psh8g6pjp9gpdksb8y6nn9n4hv1j450v1nfhy25h2n8j0f03";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-proto = mkBitscope rec {
    # note: clicking on logo produces error
    # TApplication.HandleException Executable not found: "http://bitscope.com/blog/DK/?p=DK15A"
    name = "${toolName}_${version}";
    toolName = "bitscope-proto";
    version = "0.9.FG13B";

    meta = {
      description = "Prototype oscilloscope built using the BitScope Library";
      homepage = "http://bitscope.com/blog/DK/?p=DK15A";
    };

    bins = [
      "bitscope-proto" # "start-bitscope-proto"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "1ybjfbh3narn29ll4nci4b7rnxy0hj3wdfm4v8c6pjr8pfvv9spy";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "13v4r4x3h65ya5lxi5qgim62z7l7qjvyc53hzvkjzhzvd1ab5xzl";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-console = let
    # https://trello.com/c/sgH6tDdy/58-fb28a-bitscope-console
    name = "${toolName}_${version}";
    toolName = "bitscope-console";
    version = "1.0.FK29A";
  in mkBitscope {
    inherit name toolName version;

    meta.description = "Communications program designed to make it easy to talk to any model BitScope";
    meta.longDescription = "BitScope Console is a communications program designed to make it easy to talk to any model BitScope via any supported communications link (serial, USB, LAN, Internet etc). Use it to interrogate the BitScope Virtual Machine to help write your own software for BitScope. It uses BitScope Link Library to facilitate communication. Note: you don't need the program to talk to most BitScopes, a simple terminal program will do but Console makes connection easier, uses the probe file specification and supports downstream communications to connected port adapters.";

    bins = [
      "bitscope-console" # "start-bitscope-console"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "00b4gxwz7w6pmfrcz14326b24kl44hp0gzzqcqxwi5vws3f0y49d";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "0llcvbgmwhl3dybv1c4sxxsgc4xl21rxk6bdva5a11w4w9sx6c7s";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-display = let
    name = "${toolName}_${version}";
    toolName = "bitscope-display";
    version = "1.0.EC17A";
  in mkBitscope {
    inherit name toolName version;

    meta = {
      description = "Display diagnostic application for BitScope";
      homepage = "http://bitscope.com/software/display/";
    };

    bins = [
      "bitscope-display" # "start-bitscope-display"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "05xr5mnka1v3ibcasg74kmj6nlv1nmn3lca1wv77whkq85cmz0s1";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "13csap7gmc1q19rd6qhd0z64bqafk03zfalnsrz2gxa2db5m5wlk";
    } else throw "no install instructions for ${stdenv.system}";
  };

  bitscope-server = let
    name = "${toolName}_${version}";
    toolName = "bitscope-server";
    version = "1.0.FK26A";
  in mkBitscope {
    inherit name toolName version;

    bins = [
      "bitscope-server" # "start-bitscope-server"
    ];

    src = if stdenv.system == "x86_64-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_amd64.deb";
      sha256 = "1079n7msq6ks0n4aasx40rd4q99w8j9hcsaci71nd2im2jvjpw9a";
    } else if stdenv.system == "i686-linux" then fetchurl {
      url = "http://bitscope.com/download/files/${name}_i386.deb";
      sha256 = "0kpxmx0gc83gwk2v8yqyinhc0wndlq33mb9snbmmq3yfiz4qxhq0";
    } else throw "no install instructions for ${stdenv.system}";
  };

in stdenv.mkDerivation rec {
  name = "bitscope-sh";

  dpkg = pkgs.dpkg;
  buildInputs = [
    bitscope-chart
    bitscope-console
    bitscope-display
    bitscope-dso
    bitscope-logic
    bitscope-meter
    bitscope-proto
    bitscope-server
  ];

  shellHook = ''
    export PS1="\e[1;33m$ \e[0m";
    echo $out
  '';
}
