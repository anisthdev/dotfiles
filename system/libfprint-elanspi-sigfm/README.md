# Fingerprint reader on Asus Vivobook X1502ZA (Arch)

Sensor: ELAN eFSA80SC, SPI, ACPI `ELAN7001`, paired touchpad `04f3:3104`.
Upstream libfprint does not list this touchpad ID, and its NBIS matcher
scores 0 on this sensor. This folder builds the goodix-fp-linux-dev
libfprint fork (SIGFM matcher) with the patch from
[r4nd3l/elan-3104-fingerprint-linux](https://github.com/r4nd3l/elan-3104-fingerprint-linux)
(LGPL-2.1) and a few local fixes.

Fingerprint is used only on the lock screen (hyprlock's own fprintd support).
sudo, polkit and login PAM files are stock.

## Install (fresh system or package lost)

    sh ~/dotfiles/system/libfprint-elanspi-sigfm/install.sh

Run as your user. It builds the package if it is missing (pulling build
deps with sudo), installs it, installs `spidev-bufsiz.conf` and rebuilds the
initramfs if needed, then restarts fprintd. On a fresh system pacman asks to
replace the stock `libfprint`: answer yes. Reboot if the script says the
spidev buffer changed, then enroll:

    fprintd-enroll -f right-index-finger

The sensor is a swipe sensor: slide the finger slowly, vary the position
across the 15 swipes.

## Rebuild (after an OpenCV / glib / ABI update breaks it)

Symptom: `fprintd-list $USER` errors or finds no device, or
`journalctl -u fprintd` shows a missing `libopencv_*.so.*`.

    sh ~/dotfiles/system/libfprint-elanspi-sigfm/install.sh --rebuild

The package name is not in the repos or AUR, so `pacman -Syu` and yay never
replace it. If pacman ever offers to remove `libfprint-elanspi-sigfm` in
favour of `libfprint`, answer no.

## What is customised

| What | Where | Why |
|---|---|---|
| libfprint replaced by `libfprint-elanspi-sigfm` | `PKGBUILD` here | `0x3104` device entry, SIGFM matcher, 15 enroll stages, threshold 50, gdac aliasing fix (HV capture clobbered the gain), "too hot" cap raised from 3 to ~20 min (cooldown ~10 min) so hyprlock's continuous verify survives a normal lock. Waiting for a finger costs ~4% of a core |
| spidev buffer 4096 -> 32768 | `../etc/modprobe.d/spidev-bufsiz.conf` (+ initramfs) | one frame is 16640 bytes; a smaller buffer corrupts frames and calibration times out |
| faillock reports lockouts | `/etc/pam.d/system-auth`: `silent` removed from the `preauth` line (backup `system-auth.bak`) | a lock showed up as "Sorry, try again" on a correct password; reset with `faillock --user $USER --reset` from a root TTY |
| hyprlock fingerprint | `hypr/.config/hypr/hyprlock.conf` | `auth {}` block, fingerprint icon, `$FPRINTFAIL` status line |
| lock screen recovery | `hypr/.config/hypr/looknfeel.lua` | `allow_session_lock_restore`, any key or mouse wakes a blanked screen |
| hyprlock logging | `hypr/.config/hypr/hypridle.conf`, `scripts/.local/bin/menus/power-menu` | `journalctl --user -t hyprlock` |

fprintd itself is the stock Arch package and is not modified.

## Lock screen stuck

hyprlock accepts the password at all times, even after fingerprint gives up
(3 failed swipes per lock, hardcoded in hyprlock). If it really hangs:

    # Ctrl+Alt+F2, log in, then:
    pkill -x hyprlock
    hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("hyprlock")'   # Lua-config syntax
    # Ctrl+Alt+F1 and unlock

## Undo everything

    sudo rm /etc/modprobe.d/spidev-bufsiz.conf
    sudo pacman -S libfprint      # replaces this package (confirm removal)
    sudo mkinitcpio -P
    sudo mv /etc/pam.d/system-auth.bak /etc/pam.d/system-auth   # restores `silent`
    # remove the auth {} block and the FINGERPRINT / FINGERPRINT STATUS labels from hyprlock.conf
