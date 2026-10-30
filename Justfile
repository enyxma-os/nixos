set shell := ["bash", "-uc"]

default:
    @just --list

fmt:
    alejandra .
    shfmt -w .

check:
    nix flake check
    deadnix --fail modules hosts
    statix check

vm:
    nixos-rebuild build-vm --flake .#vm
    ./result/bin/run-vm-vm
