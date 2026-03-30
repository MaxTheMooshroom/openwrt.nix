{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
let
in
{
  options = {
    networking.hostName = mkOption {
      default = "openwrt";

      # Only allow hostnames without the domain name part (i.e. no FQDNs, see
      # e.g. "man 5 hostname") and require valid DNS labels (recommended
      # syntax).
      type = types.strMatching "^[[:alnum:]]([[:alnum:]-]{0,61}[[:alnum:]])?$";

      description = ''
        The name of the machine. Leave it empty if you want to obtain it from a
        DHCP server (if using DHCP). The hostname must be a valid DNS label (see
        RFC 1035 section 2.3.1: "Preferred name syntax", RFC 1123 section 2.1:
        "Host Names and Numbers") and as such must not contain the domain part.
        This means that the hostname must start with a letter or digit,
        end with a letter or digit, and have as interior characters only
        letters, digits, and hyphen. The maximum length is 63 characters.
        Additionally it is recommended to only use lower-case characters.

        NOTE: Unlike NixOS, this OpenWrt option is required, and disallows
        underscores and empty hostnames.
      '';
    };

    networking.domain = mkOption {
      default = null;
      example = "home.arpa";
      type = types.nullOr types.str;
      description = ''
        The system domain name. Used to populate the {option}`fqdn` value.

        ::: {.warning}
        The domain name is not configured for DNS resolution purposes, see {option}`search` instead.
        :::
      '';
    };

    networking.fqdn = mkOption {
      type = types.str;
      default =
        if (cfg.hostName != "" && cfg.domain != null) then
          "${cfg.hostName}.${cfg.domain}"
        else
          throw ''
            The FQDN is required but cannot be determined from `networking.hostName`
            and `networking.domain`. Please ensure these options are set properly or
            set `networking.fqdn` directly.
          '';
      defaultText = literalExpression ''"''${networking.hostName}.''${networking.domain}"'';
      description = ''
        The fully qualified domain name (FQDN) of this host. By default, it is
        the result of combining `networking.hostName` and `networking.domain.`

        Using this option will result in an evaluation error if the hostname is empty or
        no domain is specified.

        Modules that accept a mere `networking.hostName` but prefer a fully qualified
        domain name may use `networking.fqdnOrHostName` instead.
      '';
    };

    networking.search = mkOption {
      default = [ ];
      example = [
        "example.com"
        "home.arpa"
      ];
      type = types.listOf types.str;
      description = ''
        The list of domain search paths that are considered for resolving
        hostnames with fewer dots than configured in the `ndots` option,
        which defaults to 1 if unset.
      '';
    };
  };
}
