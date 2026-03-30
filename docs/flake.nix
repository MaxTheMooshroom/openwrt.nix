{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.lib.url = ../lib;

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;

      imports = [ flake-parts.flakeModules.flakeModules ];

      flake.flakeModules.default = {
        perSystem = { pkgs, ... }: {
          packages.docs = (pkgs.nixosOptionsDoc {
            inherit (inputs.lib.lib.openwrtSystem { modules = []; }) options;
          }).optionsCommonMark;
        };
      };
    });
}
