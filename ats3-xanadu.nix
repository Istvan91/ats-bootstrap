{ lib
, ats3-source
, ats-postiats
, autoconf
, automake
, bash
, boehmgc
, fetchFromGitHub
, gmp
, makeWrapper
, stdenv
}:
stdenv.mkDerivation rec {
  pname = "ats3-xanadu";
  version = "0.0.1-alpha";

  buildInputs = [ gmp boehmgc ];
  nativeBuildInputs = [
    autoconf
    automake
    ats-postiats
    makeWrapper
  ];

  src = ats3-source;

  enableParallelBuilding = true;

  makeFlags = [ "-C srcgen/xats" ];

  preBuild = "export XATSHOME=$(pwd)";

  doCheck = true;
  checkPhase = ''
    export XATSHOME=$(pwd)
    make -C srcgen/xutl/TEST testall
    make -C srcgen/xutl/TEST/Posix testall
    make XATSOPT=../xatsopt -C srcgen/xats/TEST -f Makefile_test all
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 srcgen/xats/xatsopt $out/bin
    for d in prelude share; do
        mkdir -p $out/$d
        find $d -type f -exec install -v -m 0644 "{}" $out/$d \;
    done
    find $out -name .keeper -type f -delete
    find $out -name .gitkeep -type f -delete
  '';

  postFixup = ''
    wrapProgram $out/bin/xatsopt --set XATSHOME $out
  '';

  meta = with lib; {
    description = "Functional programming language with dependent types";
    homepage = "http://www.ats-lang.org";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ "lvkm" ];
  };
}
