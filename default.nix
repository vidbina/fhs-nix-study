{ stdenv, fetchurl, dpkg }:

stdenv.mkDerivation rec {
  name = "bitscope-dso";
  src = fetchurl {
    url = "http://bitscope.com/download/files/bitscope-dso_2.8.FE22H_i386.deb";
    sha256 = "f1058a015244dfcd04de3488873e130359150ff826c6b310d73018239e2a093f";
  };
  version = "2.8.0";

  buildInputs = [ dpkg ];
  unpackPhase = ''
    dpkg-deb -x ${src} ./
  '';

  shellHook = ''
    echo "installed to ${src}"
    echo "out is $out"
  '';
}
