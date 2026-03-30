{
  # !!! The nixpkgs library.
  lib,

  # !!! The list of modules that provides the default options for
  #     configuring OpenWrt with nix.
  baseModules,

  # !!! Additional items to make available to modules through the module
  #     parameters.
  #     eg.
  #       `extraArgs = { inherit myArg; }`
  #       ->
  #       ```nix
  #       { lib, myArg, ... }: {
  #         imports = []; options = {}; config = {};
  #       }
  #       ```
  #     For more information, see [_module.args](https://nixos.org/manual/nixos/stable/options#opt-_module.args)
  extraArgs ? {},

  # !!! Like extraArgs, these are additional items provided to modules via
  #     parameters, but these are available while imports are being evaluated.
  #     eg.
  #       `specialArgs = { inherit myModulesPath; }`
  #       ->
  #       ```
  #       { lib, myModulesPath, ... }: {
  #         imports = [ (myModulesPath + "/category/module.nix") ];
  #       }
  #       ```
  specialArgs ? {},

  # !!! The modules used to evaluate the configuration for openwrt.
  modules,
  # !!! A built-in special arg (see `specialArgs`) with the path to
  #     the file that defined `modules`, if available.
  modulesLocation ? (
    (builtins.unsafeGetAttrPos "modules" evalConfigArgs).file or null
  ),

  # !!! Used for improved error reporting. For more information, see
  #     [lib.evalModules](https://nixos.org/manual/nixpkgs/stable/#module-system-lib-evalModules-param-prefix)
  prefix ? [],
}@evalConfigArgs:
let
  evalModulesMinimal = { prefix ? [], modules ? [], specialArgs ? {} }:
    lib.evalModules {
      inherit prefix modules;

      class = "openwrt";

      specialArgs = {
        modulesPath =
          assert lib.assertMsg
            (builtins.pathExists modulesLocation)
            "modulesLocation argument for lib.openwrtSystem does not exist! Value: ${modulesLocation}";

          toString (
            if    (builtins.tryEval (builtins.readFile modulesLocation))
            then  dirOf modulesLocation
            else  modulesLocation
          );
      } // specialArgs;
    };

  allUserModules =
    if    modulesLocation == null
    then  modules
    else  map (lib.setDefaultModuleLocation modulesLocation) modules;

  noUserModules = evalModulesMinimal {
    inherit prefix specialArgs;
    modules = baseModules ++ [ modulesModule ];
  };

  modulesModule = {
    config = {
      _module.args = {
        inherit noUserModules baseModules modules;
      };
    };
  };

  openwrtWithUserModules = noUserModules.extendModules {
    modules = allUserModules;
  };

  withExtraAttrs = configuration: configuration // {
    inherit (configuration._module.args) pkgs;
    inherit lib;
    extendModules = args: withExtraAttrs (configuration.extendModules args);
  };
in
  withExtraAttrs openwrtWithUserModules
