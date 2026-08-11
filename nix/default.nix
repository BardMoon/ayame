{
  nixpkgs,
  ...
}@inputs:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  forAllSystems =
    f:
    nixpkgs.lib.genAttrs systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      f system pkgs
    );
in
{
  packages = forAllSystems (
    _: pkgs: rec {
      default = ayame;
      ayame = pkgs.kdePackages.callPackage ./pkgs/ayame.nix { };
    }
  );

  devShells = forAllSystems (
    _: pkgs: {
      default = pkgs.callPackage ./dev.nix { inherit inputs; };
    }
  );

  formatter = forAllSystems (
    _: pkgs:
    let
      treefmt = import ./formatter.nix { inherit pkgs inputs; };
    in
    treefmt.wrapper
  );
}
