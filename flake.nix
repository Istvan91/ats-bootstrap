{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ats3-source.url = "github:githwxi/ats-xanadu";
    ats3-source.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, ats3-source, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          packages =
            with pkgs; rec {
              ats-anairiats = callPackage ./ats1-anairiats.nix { };
              ats-postiats = callPackage ./ats2-postiats.nix {
                ats-anairiats = ats-anairiats;
              };
              ats-xanadu = callPackage ./ats3-xanadu.nix {
                ats-postiats = ats-postiats;
                ats3-source = ats3-source;
              };
              ats = ats-anairiats;
              ats2 = ats-postiats;
              ats3 = ats-xanadu;
            };

          legacyPackages = packages;
        });
}
