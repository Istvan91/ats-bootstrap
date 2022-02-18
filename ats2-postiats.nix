{ lib
, ats
, autoconf
, automake
, bash
, fetchFromGitHub
, gmp
, makeWrapper
, stdenv
, withContrib ? true
, withEmacs ? true
}:
stdenv.mkDerivation rec {
  pname = "ats2";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "githwxi";
    repo = "ats-postiats";
    rev = "9018fdb532cf6542c2f9427a86b55db651afbd67";
    sha256 = "I2vQ57v7W1ksPf11FBEZl4QhhQByjuaQyG2QzbsB004=";
  };

  buildInputs = [ gmp ];
  nativeBuildInputs = [
    autoconf
    automake
    ats
    makeWrapper
  ];

  enableParallelBuilding = true;

  postPatch = ''
    find \
      -iname "Makefile*" \
      -type f \
      -exec \
        sed -i \
          -e 's/\/bin\/bash/${lib.replaceStrings ["/"] ["\\/"] (toString bash)}\/bin\/bash/' \
          -e 's/make -C/\$(MAKE) -C/' \
          -e 's/make -f/$(MAKE) -f/' \
          -e '/MAKE=make/d' \
          -e 's/CCOMP=gcc/CCOMP=$(CC)/' \
          {} \;

    patchShebangs doc/DISTRIB/ATS-Postiats/autogen.sh
    sed -i '/env.sh.in/s/^#//g' doc/DISTRIB/Makefile

    # Workaround: release 0.4.2 has the wrong version number
    grep -r --files-with-matches --null "0\.4\.2" * | xargs --null sed -i 's/0\.4\.1/0.4.2/g'
    sed -i 's/MICRO_VERSION 1/MICRO_VERSION 2/g' src/pats_basics.sats
  '';

  configurePhase = ''
    export PATSHOME=$(pwd)
    # make -f codegen/Makefile_atslib
    make -f Makefile_devl
  '';

  buildPhase = ''
    local flags=''${enableParallelBuilding:+-j''${NIX_BUILD_CORES} -l''${NIX_BUILD_CORES}}
    # bootstraping
    make $flags -C src/ CBOOTgmp
    make $flags -C src/CBOOT/libats
    make $flags -C src/CBOOT/libc
    make $flags -C src/CBOOT/prelude
    make $flags -C doc/DISTRIB atspackaging
  '' + lib.optionalString withContrib ''
    make -C doc/DISTRIB atscontribing
  '' + ''
    # building
    pushd doc/DISTRIB/ATS-Postiats || exit
      make cleanall
      ./configure --prefix=$out
      make
    popd || exit
  '';

  installPhase = ''
    mkdir -p $out
    make -C ./doc/DISTRIB/ATS-Postiats install
  '' + lib.optionalString withContrib ''
    pushd ./doc/DISTRIB/ATS-Postiats-contrib/contrib || exit
        find -type f -exec install -m 0644 "{}" $out/lib/ats2-postiats-${version}/contrib/ \;
    popd || exit
  '' + lib.optionalString withEmacs ''
    local siteLispDir=$out/share/emacs/site-lisp/ats2
    mkdir -p $siteLispDir
    install -m 0644 -v utils/emacs/*.el $siteLispDir
  '' + ''
    find $out -name .keeper -type f -delete
  '';

  setupHook = builtins.toFile "setupHook.sh" (''
    export PATSHOME=@out@/lib/ats2-postiats-@version@
  '' + lib.optionalString withContrib ''
    export PATSHOMERELOC=@out@/lib/ats2-postiats-@version@
  '');


  meta = with lib; {
    description = "Functional programming language with dependent types";
    homepage = "http://www.ats-lang.org";
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ "lvkm" ];
  };
}
