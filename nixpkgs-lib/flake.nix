{
  description = "Local additions to nixpkgs' lib attrset.";

  inputs.nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
  inputs.ext-attrsets = { flake = false; url = ./attrsets.nix; };
  inputs.ext-modules  = { flake = false; url = ./modules.nix; };

  outputs = { nixpkgs-lib, ... }@inputs:
    let
      inherit (nixpkgs-lib) lib;

      overlay = lib.composeManyExtensions [
        (import inputs.ext-attrsets)
        (import inputs.ext-modules)
        (_: _: { THISISATEST = false; })
      ];

      lib' = lib.fix' (lib.extends overlay lib.__unfix__);
    in {
      lib = lib';
    };
}
