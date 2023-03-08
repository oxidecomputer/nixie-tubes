# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

{ config, pkgs, lib, ... }: {
  options.services.oxide-ssh-init = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Enables fetching SSH keys from the Oxide cidata volume or the EC2
        instance metadata service.
      '';
    };
  };

  config = lib.mkIf config.services.oxide-ssh-init.enable {
    systemd.services.oxide-ssh-init = {
      description = "Add SSH keys from the Oxide cidata volume or EC2 IMDS";
      script = builtins.readFile ./ssh-init.sh;
      path = with pkgs; [ coreutils curl jq mtools ];

      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      before = [ "sshd.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ConditionPathExists = "!/root/.ssh/authorized_keys";
      };
    };
  };
}
