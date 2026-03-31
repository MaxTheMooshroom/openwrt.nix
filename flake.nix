{
  description = "A flake interface for building openwrt images using nix modules";

  inputs = {
    nixpkgs-lib.url = ./nixpkgs-lib;
    nixpkgs-lib.inputs.nixpkgs-lib.url = "github:NixOS/nixpkgs/25.11?dir=lib";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-lib";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    docs.url      = ./docs;

    lib = {
      url = ./lib;
      inputs.flake-parts.follows = "flake-parts";
    };

    templates.url = ./templates;
    tests.url     = ./tests;

    devshells.url = ./devshells;
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;

      imports = lib.importDefaultFlakeModules (with inputs; [
        inputs.lib
        docs
        # templates
        # tests

        # devshells
      ]);

      # include some references
      flake.openwrtConfigurations = {
        # used to generate docs
        noUserModules = self.lib.openwrtSystem { modules = []; };
      };
    });
}
