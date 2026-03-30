{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    network-ifaces = { flake = false; url = ./network-interfaces.nix; };
  };

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = [];

      imports = [ flake-parts.flakeModules.modules ];

      flake.modules.openwrt.all = {
        imports = [
          (import inputs.network-ifaces)
        ];
      };
    });
}
