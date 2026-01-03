#!/usr/bin/env bash

systemctl enable podman.socket
systemctl enable tailscaled.service
systemctl enable flatpak-preinstall.service
systemctl --global enable bazaar.service
systemctl --global disable sunshine.service
