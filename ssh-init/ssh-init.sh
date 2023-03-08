# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# shellcheck shell=bash

umask 0077
mkdir -p /root/.ssh

# On Oxide, instance metadata is provided by a FAT volume labeled "cidata".
# This reads the `meta-data` from the root of the volume.
if [[ -b /dev/disk/by-label/cidata ]]; then
    mcopy -i /dev/disk/by-label/cidata ::/meta-data - | jq -r '."public-keys"[]' > /root/.ssh/authorized_keys
    exit 0
fi

# If there was no cidata volume, we might be in EC2, or somewhere that
# implements its instance metadata service. If we're not, this will just
# silently fail.

curl_retry() {
    curl --silent --show-error --retry 10 --retry-delay 1 --fail --connect-timeout 1 "$@"
}
for imds_host in 169.254.169.254 "[fd00:ec2::254]"; do
    token=$(curl_retry -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 60" "http://$imds_host/latest/api/token")
    if [[ -n $token ]]; then
        curl_retry -H "X-aws-ec2-metadata-token: $token" -o /root/.ssh/authorized_keys \
            "http://$imds_host/latest/meta-data/public-keys/0/openssh-key"
        exit 0
    fi
done
