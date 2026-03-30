{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ flake-parts.flakeModules.flakeModules ];

      flake.flakeModules.default = {
        perSystem = { self', pkgs, ... }: {
          devShells.default = self'.devShells.openwrt-builder;

          devShells.openwrt-builder = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              git
              pkg-config
              ncurses
              unzip
              (python3.withPackages (ps: [ps.setuptools]))
              cdrtools
              swig
            ];
          };
        };
      };
    };
}
