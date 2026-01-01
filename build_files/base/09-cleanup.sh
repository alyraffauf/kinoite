#!/usr/bin/bash

set -ouex pipefail

# Hide Desktop Files. Hidden removes mime associations
for file in htop nvtop; do
    if [[ -f "/usr/share/applications/${file}.desktop" ]]; then
        desktop-file-edit --set-key=Hidden --set-value=true /usr/share/applications/${file}.desktop
    fi
done

# Hide Discover entries by renaming them (allows for easy re-enabling)
discover_apps=(
  "org.kde.discover.desktop"
  "org.kde.discover.flatpak.desktop"
  "org.kde.discover.notifier.desktop"
  "org.kde.discover.urlhandler.desktop"
)

for app in "${discover_apps[@]}"; do
  if [ -f "/usr/share/applications/${app}" ]; then
    mv "/usr/share/applications/${app}" "/usr/share/applications/${app}.disabled"
  fi
done

# These notifications are useless and confusing
rm /etc/xdg/autostart/org.kde.discover.notifier.desktop

# Use Bazaar for Flatpak refs
echo "application/vnd.flatpak.ref=io.github.kolunmi.Bazaar.desktop" >> /usr/share/applications/mimeapps.list

systemctl enable flatpak-preinstall.service
systemctl --global enable bazaar.service

# Disable third-party repos
for repo in negativo17-fedora-multimedia tailscale fedora-cisco-openh264; do
    if [[ -f "/etc/yum.repos.d/${repo}.repo" ]]; then
        sed -i 's@enabled=1@enabled=0@g' "/etc/yum.repos.d/${repo}.repo"
    fi
done
