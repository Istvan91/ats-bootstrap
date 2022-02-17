# Nix flake to bootstrap ATS3 (ATS-Xanadu)

This repository includes ATS1 to ATS3. They are bootstrapped, starting with the
C sources of ATS1. (TODO: bootstrap ATS1 with by the ocaml source)

Current versions:

- ATS1 (Anairiats): 0.2.12
- ATS2 (Postiats): 0.4.2
- ATS3 (Xanadu): master (2022-02-17)

ATS2 is patched to report the correct version, but otherwise uses the 0.4.2
tagged commit.

Technically building for aarch64 and/or osx should work, but was not tested.

## Usage

nix with flake support is required (version >=2.4).

```cli
# current master
nix shell github:Istvan91/ats-bootstrap/#ats3
# use ats2 with its long name:
nix shell github:Istvan91/ats-bootstrap/#ats-postiats
```
