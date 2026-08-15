default:
    @just --list

update-ayame:
    nix flake udpate origami
    cargo update origami
