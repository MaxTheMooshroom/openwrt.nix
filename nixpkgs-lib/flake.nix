{
  description = "Local additions to nixpkgs' lib attrset.";

  inputs.nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-25.11-small?dir=lib";

  inputs.ext-attrsets = { flake = false; url = ./attrsets.nix;  };
  inputs.ext-modules  = { flake = false; url = ./modules.nix;   };

  outputs = { nixpkgs-lib, ... }@inputs:
    let
      inherit (nixpkgs-lib) lib;

      overlay = lib.composeManyExtensions [
        (import inputs.ext-attrsets)
        (import inputs.ext-modules)
      ];

      lib' = lib.fix' (lib.extends overlay lib.__unfix__);
    in {
      lib = lib';
    };
}
