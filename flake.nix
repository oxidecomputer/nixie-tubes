# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

{
  inputs = { };

  outputs = { self }: {

    # Creates a one-shot systemd service to set up SSH keys for the root user
    # based on either a FAT-formatted `cidata` volume as used on the Oxide rack
    # or EC2's instance metadata service.
    nixosModules.ssh-init = ./ssh-init;

  };
}
