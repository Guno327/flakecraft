{
  config,
  lib,
  ...
}: let
  cfg = config.services.flakecraft;
in
  with lib; {
    options.services.flakecraft = {
      enable = mkEnableOption "enable flakecraft server";

      name = mkOption {
        type = types.str;
        default = "world";
        description = "Name of the server, will set subdir name";
      };

      dir = mkOption {
        type = types.path;
        default = "/var/lib/flakecraft";
        description = "Working dir for flakecraft";
      };

      ports = mkOption {
        type = types.listOf types.str;
        default = ["25565:25565"];
        description = "List of port mappings to open in the container";
      };

      environment = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Attribute set of any variables declared for the container image";
      };
    };

    config = mkIf cfg.enable {
      users = {
        users.flakecraft = {
          name = "flakecraft";
          isSystemUser = true;
          group = "flakecraft";
          createHome = false;
          uid = 25565;
        };
        groups.flakecraft = {
          gid = 25565;
        };
      };

      systemd.tmpfiles.rules = [
        "d ${cfg.dir} 0755 flakecraft flakecraft -"
        "d ${cfg.dir}/${cfg.name} 0755 flakecraft flakecraft"
      ];

      virtualisation.oci-containers.containers."flakecraft-${cfg.name}" = {
        inherit (cfg) ports;

        autoStart = true;
        image = "itzg/minecraft-server";
        user = "25565:25565";

        environment = mkMerge [
          cfg.environment

          {
            UID = mkForce "25565";
            GID = mkForce "25565";
          }
        ];

        volumes = [
          "${cfg.dir}/${cfg.name}:/data"
        ];
      };
    };
  }
