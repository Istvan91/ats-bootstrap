{ lib
, autoconf
, automake
, bison
, fetchFromGitHub
, gmp
, makeWrapper
, pkgconfig
, stdenv
, withContrib ? true
}:
stdenv.mkDerivation rec {
  pname = "ats-anairiats";
  version = "0.2.12";

  buildInputs = [ gmp ];
  nativeBuildInputs = [
    autoconf
    automake
    bison
    makeWrapper
    pkgconfig
  ];
  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "githwxi";
    repo = "ats-anairiats";
    rev = "07a031dcfdcc942baf88da12a4db87cf62ec5a86";
    sha256 = "zF3cO0IgEU8btt0M/ci0rCbMNldEJNJuAwe56dIUDMw=";
  };

  patchPhase = ''
    find -iname Makefile -exec \
      sed -i -e 's/make -C/\$(MAKE) -C/' \
             -e 's/^MAKE=/#MAKE=/' {} \
             -e 's/^MAKEFLAGS/#MAKEFLAGS/' \
     \;
  '';

  preConfigure = "autoreconf -ivf || true";
  preBuild = "mkdir -p bootstrap1";

  installPhase = ''
    # cleanup before installing
    rm -rf prelude/GEIZELLA
    pushd ccomp/runtime
      unlink GCATS
      mv GCATS1 GCATS
      rm -rf GCATS0 GCATS2
    popd

    mkdir -p $out/bin
    for d in ccomp/runtime libats libc libatsdoc prelude utils/atsdoc; do
      install -v -d $out/$d
      find $d -type f -exec install -m 644 -D \{} $out/\{} \;
    done

    mkdir -p $out/ccomp/runtime/GCATS
    install -m 644 ccomp/runtime/GCATS/* $out/ccomp/runtime/GCATS/

    for f in ccomp/lib/*.a ccomp/lib64/*a config.h; do
      install -m 644 -D "$f" "$out/$f"
    done

    install -m 755 bin/* $out/bin

    while IFS= read -r -d $'\0' program; do
        wrapProgram "$program" --set ATSHOME "$out" --set ATSHOMERELOC "ATS-${version}"
    done <  <(find $out/bin -maxdepth 1 -type f  -print0)
  '' + lib.optionalString
    withContrib ''
    install -v -d $out/contrib
    find contrib -type f -exec install -m 644 -D \{} $out/\{} \;
  '';

  setupHook = builtins.toFile "setupHook.sh" ''
    export ATSHOME=@out@
    export ATSHOMERELOC=ATS-${version}
  '';
}
