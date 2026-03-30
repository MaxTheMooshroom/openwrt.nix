# { openwrt-source, ... }@inputs:
# { self, ... }:
# {
#   config.genFeeds-data =
#     let
#       feeds-raw = builtins.readFile (
#         openwrt-source + "/feeds.conf.default"
#       );
#
#       lines = s:
#         builtins.filter
#           (x: x != "" && x != [])
#           (builtins.split "\n" s);
#
#       matchFeed = s:
#         builtins.match
#           "src-git ([[:alnum:]_-]+) ([^;\\^]+)([;\\^])([[:alnum:]\\._-]+)"
#           s;
#
#       feeds-components = builtins.map matchFeed (lines feeds-raw);
#
#       feeds-attrs =
#         with builtins;
#         map
#           (x:
#           let
#             name = elemAt x 0;
#             switch = { ";" = "ref"; "^" = "rev"; };
#             checkout-type = switch.${elemAt x 2};
#           in
#           {
#             inherit name;
#
#             value = {
#               inherit name;
#               url = elemAt x 1;
#
#               ${checkout-type} = elemAt x 3;
#             };
#           })
#           feeds-components;
#     in
#       builtins.listToAttrs feeds-attrs;
#
#   config.flake.genFeeds =
#     let template = { type = "git"; }; in
#     builtins.mapAttrs
#       (_: x: template // x // { src = builtins.fetchTree (template // x); })
#       (self.genFeeds-data openwrt-source);
# }
null
