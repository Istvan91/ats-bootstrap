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
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        rec {
          packages =
            with pkgs; rec {
              ats = callPackage ./ats1-anairiats.nix { };
              ats2 = callPackage ./ats2-postiats.nix {
                ats = ats;
              };
              ats3 = callPackage ./ats3-xanadu.nix {
                ats2 = ats2;
                ats3-source = ats3-source;
              };
            };
          legacyPackages = packages;

          overlay = prev: final: packages;

          # apps = pkgs.lib.mapAttrs
          #   (n: v: flake-utils.lib.mkApp {
          #     drv = v;
          #   })
          #   packages;
          # {
          #   ats = packages.ats;
          #   ats2 = packages.ats2;
          #   ats3 = packages.ats3;
          # };
        });
}
