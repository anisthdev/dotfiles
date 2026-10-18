#!/bin/sh
# Build (if needed) and install the patched libfprint for the ELAN eFSA80SC
# fingerprint sensor, plus the spidev buffer size it needs.
#
#   sh install.sh            build only if the package is missing, then install
#   sh install.sh --rebuild  always rebuild (after an OpenCV / glib update)
#
# Run as your user, not with sudo: makepkg refuses to run as root.
set -eu

cd "$(dirname "$0")"

if [ "$(id -u)" -eq 0 ]; then
  echo "run as your user, not root (makepkg refuses root)" >&2
  exit 1
fi

pkg=$(makepkg --packagelist | grep -v -- '-debug-')

if [ "${1:-}" = "--rebuild" ] || [ ! -f "$pkg" ]; then
  # -s installs missing build dependencies through sudo pacman
  makepkg -sf --nocheck --noconfirm
fi

# no --noconfirm: on a fresh system pacman asks to replace the stock libfprint
sudo pacman -U --needed "$pkg"

# one sensor frame is 16640 bytes; the default 4096-byte spidev buffer corrupts it
conf=../etc/modprobe.d/spidev-bufsiz.conf
if ! cmp -s "$conf" /etc/modprobe.d/spidev-bufsiz.conf; then
  sudo install -Dm644 "$conf" /etc/modprobe.d/spidev-bufsiz.conf
  sudo mkinitcpio -P
  echo "spidev buffer size changed: reboot before using the sensor"
fi

sudo systemctl restart fprintd
fprintd-list "$USER"
