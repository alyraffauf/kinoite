#!/usr/bin/env bash

set -ouex pipefail

rsync -rvKl /ctx/system_files/ /

/ctx/base/01-packages.sh

/ctx/base/02-workarounds.sh

/ctx/base/03-systemd.sh

/ctx/base/09-cleanup.sh

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
