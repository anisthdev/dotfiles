# dotfiles

My Arch + Hyprland desktop. The shell is quickbar; everything else is a
program of its own (mine are packaged as `totoro-*`, built from
github.com/anisthdev), meeting the others only through commands on PATH,
D-Bus, sockets and documented files. No config here runs anything from a
source checkout, so `~/Projects` is only where I work on them.

## A new machine

On a fresh Arch install with `base-devel` and `git`, as your user:

```sh
git clone https://github.com/anisthdev/dotfiles ~/dotfiles
~/dotfiles/bootstrap            # or a step at a time: ./bootstrap packages aur own link system services
chsh -s /usr/bin/fish           # fish on tty1 starts Hyprland through uwsm
```

`bootstrap` installs the packages (`packages/pacman.txt`, `packages/aur.txt`),
builds my own from their repos (`packages/own.txt`), stows every package
here into `~`, installs `system/` into `/etc` and `/usr/local` and enables
the system and user services. Run again, it leaves what's done alone.
`./bootstrap fingerprint` adds the patched libfprint for this laptop's ELAN
sensor.

Then by hand:

- **Packages from nowhere bootstrap fetches**: `packages/manual.txt`.
- **Secrets, kept out of git**:
  - `~/.config/quickbar/calendars` (iCal addresses) and
    `~/.config/quickbar/jackett` (`api_key=`, from Jackett's dashboard)
  - `~/.config/reel/tmdb_token`
  - `rclone config` for the `gdrive:` remote, then
    `systemctl --user start rclone-gdrive`
  - SSH and GPG keys; the work units (`*-ssh-portf.service`)
- **transmission-daemon**: `~/.config/transmission-daemon/settings.json`,
  with `"script-torrent-done-filename": "/usr/bin/reel-sort"`.
- **trakt-scrobbler**: `uv tool install trakt-scrobbler`, then `trakts auth`.
- **Firefox**: the `asif` and `gemini` profiles (`firefox -P`), and foxkit's
  extension.
- **The phone**: handoff's app (its repo's `android/`), then `handoffd pair`.
- **Colours**: pick a wallpaper (Super+Ctrl+Space); matugen writes every
  app's palette from it.

## Layout

Each top-level folder is a stow package mirroring `~`
(`hypr/.config/hypr` → `~/.config/hypr`). `systemd`, `dbus` and `share` are
stowed file by file, so programs can still write next to them.

- `system/`: files for `/etc` and `/usr/local`, installed by `bootstrap system`.
- `packages/`: the package lists.
- `scripts/.local/bin/`: my small commands (`toggle-handoff`, `brightness`,
  `phone-connect`, `vpn-bypass`, …).

What quickbar offers other programs and reads from them is in its
`docs/protocols.md`.
