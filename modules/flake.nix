{
  description = "Module definitions for configuring OpenWRT";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    misc.url = ./misc;
    misc.inputs.flake-parts.follows = "flake-parts";

    packages.url = ./packages;
    packages.inputs.flake-parts.follows = "flake-parts";

    tasks.url = ./tasks;
    tasks.inputs.flake-parts.follows = "flake-parts";
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = [];

      imports = [ flake-parts.flakeModules.modules ];

      flake.modules.openwrt.all = {
        imports = [
          inputs.misc.modules.openwrt.all
          inputs.packages.modules.openwrt.all
          inputs.tasks.modules.openwrt.all
        ];
      };
    });
}
