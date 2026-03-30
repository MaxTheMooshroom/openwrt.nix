final: lib:
let
  modules = lib.modules // {
    importDefaultFlakeModules =
      with builtins;
      flakeInputs:
        assert lib.assertMsg
          (all (x: (x._type or null) == "flake") flakeInputs)
          "All values in the list provided to importDefaultFlakeModules must be flakes.";

        assert lib.assertMsg
          (all (x: x ? flakeModules.default) flakeInputs)
          "All values in the list provided to importDefaultFlakeModules must have ``";

        map (final.getAttrFromPath' "flakeModules.default") flakeInputs;
  };
in
{
  inherit modules;

  inherit (modules)
    importDefaultFlakeModules
    ;
}
