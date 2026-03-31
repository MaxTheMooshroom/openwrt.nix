{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    modules.url = ../modules;

    eval-config = { flake = false; url = ./eval-config.nix; };
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      imports = [ flake-parts.flakeModules.flakeModules ];

      flake.lib = {
        # mirrors the interface and functionality of
        # `(github:NixOS/nixpkgs/nixos-25.11).lib.nixosSystem`
        openwrtSystem = args:
          import inputs.eval-config ({
            inherit lib;

            baseModules = [ (inputs.modules.modules.openwrt.all) ];
            # baseModules = [];

            modulesLocation = inputs.modules.outPath;
            modules = args.modules ++ [
              # mirrors `lib.nixosSystem`
              # https://github.com/NixOS/nixpkgs/tree/nixos-25.11/flake.nix#L64
              ({ config, pkgs, lib, ... }: {
                # config.openwrt.flake.source = self.outPath;
              })
            ];
          } // builtins.removeAttrs args ["modules"]);
      };

      flake.flakeModules.default.flake.lib.openwrtSystem = self.lib.openwrtSystem;
    });
}
