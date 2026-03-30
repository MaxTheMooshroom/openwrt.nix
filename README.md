
# Nix-OpenWRT

[![](https://github.com/jpoehnelt/in-solidarity-bot/raw/main/static//badge-flat.png)](https://github.com/apps/in-solidarity)

***This is still heavily in development and does not yet even have
the core functionality.***

This project aims to provide an [OpenWRT](https://openwrt.org/) builder
for nix, using the nix module system. The `openwrtSystem {}` function is
intentionally designed to mirror `nixosSystem {}` function as closely as
possible.

## Quickstart

```nix
{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.openwrt-nix.url = "github:MaxTheMooshroom/openwrt.nix";

  outputs = { self, flake-parts, openwrt-nix, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;

      # adds the following flake-parts options:
      # - `flake.openwrtModules."<name>"`
      # - `flake.openwrtModule` -> `flake.openwrtModules.default`
      # - `flake.openwrtConfigurations."<hostname>"`
      imports = [ openwrt-nix.flakeModules.default ];

      flake.openwrtConfigurations.my-router = openwrt-nix.lib.openwrtSystem {
        # specialArgs = {};
        # prefix = [];
        modules = [ self.openwrtModules.default ];
      };

      flake.openwrtModules.default = { ... }: {
        networking.hostName = "my-router";
        # ...
      };
    });
}
```

Then run `nix flake build .#openwrtConfigurations.my-router`

## Getting Started

Let's start with a basic flake:
```nix
{
  description = "My OpenWRT configuration(s)";

  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.openwrt-nix.url = "github:MaxTheMooshroom/openwrt.nix";

  outputs = { self, flake-parts, openwrt-nix, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ lib, ... }: {
      systems = lib.systems.flakeExposed;

      imports = [ openwrt-nix.flakeModules.default ];

      flake.openwrtConfigurations.my-router = openwrt-nix.lib.openwrtSystem {
        modules = [ self.openwrtModule ];
      };

      flake.openwrtModules.default = _: {};
    });
}
```

This is the (nearly) minimal definition for producing an OpenWRT firmware
image using Nix.

Next we need to add definitions for the required options. The required
options are:
- `openwrt.system.target`
    - The target to build OpenWrt for. Uses the `Generic` subtarget and the
      corresponding default profile unless otherwise specified.
- `networking.hostName`
    - The hostname used by the target device.
- `nixpkgs.pkgs`
    - The nixpkgs instance to use for building the OpenWrt image.

