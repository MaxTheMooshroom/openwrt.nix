{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11-small";

    markdown-tool = { flake = false; url = "github:johnlepikhin/markdown-tool"; };
  };


  outputs = { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;

      imports = [ flake-parts.flakeModules.flakeModules ];

      perSystem = { pkgs, ... }: {
        packages.markdown-tool = pkgs.rustPlatform.buildRustPackage {
          pname = "markdown-tool";
          version = "2.1.1";

          src = inputs.markdown-tool;
          cargoHash = "sha256-UAxaes3nbXvCot1WDkGSF0Iaj3NupfhRKlgXx04MmS8=";

          meta = {
            mainProgram = "markdown-tool";
            description = "A CLI utility for converting Markdown into AST and vice versa";
            homepage = "https://github.com/johnlepikhin/markdown-tool";
            license = lib.licenses.mit;
          };
        };
      };

      flake.flakeModules.default = { self, ... }: {
        perSystem = { system, self', lib, pkgs, ... }: {
          packages.docs' =
            (pkgs.nixosOptionsDoc {
              inherit (self.openwrtConfigurations.noUserModules) options;
            })
            .optionsCommonMark;

          packages.docs = pkgs.runCommand "openwrt-nix-docs.html"
            {
              nativeBuildInputs = [
                inputs.self.packages.${system}.markdown-tool
              ];
            }
            ''
              markdown-tool convert-to html < ${self'.packages.docs'} > $out
            '';
        };
      };
    });
}
