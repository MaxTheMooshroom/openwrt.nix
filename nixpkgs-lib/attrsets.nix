final: lib:
let
  attrsets = lib.attrsets // {
    getAttrFromPath' =
      attrPath: lib.attrsets.getAttrFromPath (lib.splitString "." attrPath);

    recursiveConcatOrUpdateUntil =
      with builtins;
      pred: lhs: rhs:
      let
        concatOrUpdate = here: values:
          if all isList values
          then lib.reverseList (concatLists values)
          else
            if pred here (elemAt values 1) (head values)
            then head values
            else f here values;

        f = attrPath:
          zipAttrsWith (
            name: values:
              if    length values == 1
              then  head values
              else  concatOrUpdate (attrPath ++ [ name ]) values
          );
      in
        f [ ] [ rhs lhs ];

    recursiveConcatOrUpdate = lhs: rhs:
      attrsets.recursiveConcatOrUpdateUntil
        (path: lhs: rhs: !(builtins.isAttrs lhs && builtins.isAttrs rhs))
        lhs
        rhs;
  };
in
{
  inherit attrsets;

  inherit (attrsets)
    getAttrFromPath'
    recursiveConcatOrUpdateUntil
    recursiveConcatOrUpdate
    ;
}
