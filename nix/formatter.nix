{ pkgs, inputs, ... }:
let
  treefmtModule = inputs.treefmt-nix.lib.evalModule pkgs {
    projectRootFile = "flake.nix"; # .git/config
    programs = {
      # Nix
      nixfmt.enable = true;
      statix.enable = true;
      deadnix.enable = true;

      # shfmt.enable = true;
      just.enable = true;

      # biome.enable = true;
    };
    settings = {
      global.excludes = [ ]; # https://github.com/numtide/treefmt-nix/issues/171
      biome = {
        includes = [
          "*.json"
        ];
      };

      shfmt = {
        includes = [ "*.sh" ];
      };
    };
  };
in
treefmtModule.config.build
