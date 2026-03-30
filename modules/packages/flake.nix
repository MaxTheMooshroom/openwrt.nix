{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      imports = [ flake-parts.flakeModules.modules ];

      flake.modules.openwrt.all = {
        imports = [];
      };
    });
}
