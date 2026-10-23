#!/usr/bin/env python3
"""Rebuild Material-Papirus: Material Symbols (Rounded, filled) for the GTK
file manager sidebar icons and the folder glyphs, everything else inherited
from Papirus.

Add a sidebar icon by adding a line to ICONS, or a folder to FOLDERS, and
run ./build.py. Material names: https://fonts.google.com/icons
Brand logos Material lacks come from Simple Icons (https://simpleicons.org),
written as "simple-icons:<slug>".
"""
import os
import re
import shutil
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
PAPIRUS = "/usr/share/icons/Papirus"
CDN = "https://cdn.jsdelivr.net/npm/@material-symbols/svg-400@0.48.1/rounded"
SIMPLE_ICONS = "https://cdn.jsdelivr.net/npm/simple-icons@16.35.0/icons"

# GTK icon name (without -symbolic) -> Material Symbols name
ICONS = {
    "document-open-recent": "schedule",
    "starred": "star",
    "user-home": "home",
    "user-desktop": "desktop_windows",
    "folder-documents": "description",
    "folder-download": "download",
    "folder-music": "music_note",
    "folder-pictures": "image",
    "folder-videos": "movie",
    "folder": "folder",
    "folder-remote": "cloud",
    "user-trash": "delete",
    "user-trash-full": "delete",
    "network-workgroup": "lan",
    "network-computer": "lan",
    "drive-harddisk": "hard_drive",
    "drive-removable-media": "hard_drive",
    "media-eject": "eject",
}

# Papirus folder (without .svg) -> Material Symbols glyph drawn on it
FOLDERS = {
    "folder-documents": "description",
    "folder-download": "download",
    "folder-music": "music_note",
    "folder-pictures": "image",
    "folder-videos": "movie",
    "folder-projects": "code",
    "folder-games": "sports_esports",
    "folder-books": "menu_book",
    "folder-notes": "sticky_note_2",
    "folder-templates": "file_copy",
    "folder-publicshare": "share",
    "folder-remote": "cloud",
    "user-desktop": "desktop_windows",
    "user-home": "home",
    "folder-google-drive": "simple-icons:googledrive",
    # not in Papirus, so nothing uses these by default; pick them as a
    # folder's custom icon
    "folder-dotfiles": "terminal",
    "folder-work": "work",
    "folder-study": "school",
    "folder-wallpapers": "wallpaper",
}

HEADER = """[Icon Theme]
Name=Material-Papirus
Comment=Papirus, with Material Symbols (Rounded, filled) for the sidebar icons and folder glyphs
Inherits=Papirus,breeze,hicolor
Directories={dirs}

[symbolic/places]
Context=Places
Size=16
MinSize=8
MaxSize=512
Type=Scalable

# Full-colour Papirus icons for the same names, linked in so GTK finds them
# here before falling back to our symbolic ones in the main file views
"""


def material(name):
    if name.startswith("simple-icons:"):
        url = f"{SIMPLE_ICONS}/{name.split(':')[1]}.svg"
    else:
        url = f"{CDN}/{name}-fill.svg"
    with urllib.request.urlopen(url) as r:
        return r.read().decode()


def folder_icon(rel, glyph):
    """Papirus's plain folder at this size, with a Material glyph centred on
    its front panel in the colour Papirus uses for its own glyphs; reading
    the installed files keeps papirus-folders' colour choice"""
    base = open(os.path.join(PAPIRUS, rel, "folder.svg")).read()
    # the front panel is the last opaque, coloured rect (the paper behind
    # it is #e4e4e4, the shadows have opacity)
    front = [dict(re.findall(r'(\w+)="([^"]*)"', r)) for r in
             re.findall(r"<rect ([^>]*)/>", base)]
    front = [r for r in front if "opacity" not in r["style"]
             and "#e4e4e4" not in r["style"]][-1]
    x, y, w, h = (float(front[k]) for k in ("x", "y", "width", "height"))
    papirus = open(os.path.join(PAPIRUS, rel, "folder-documents.svg")).read()
    colour = re.findall(r"fill:(#[0-9a-fA-F]{6})", papirus)[-1]
    # Material glyphs fill about two thirds of their box and Simple Icons
    # logos all of it; this makes both about as tall as Papirus's (just over
    # half the panel)
    vx, vy, size = (float(v) for v in
                    re.search(r'viewBox="([^"]+)"', glyph).group(1).split()[:3])
    box = h * (0.8 if size == 960 else 0.62)
    d = re.search(r'<path d="([^"]+)"', glyph).group(1)
    path = (f'<path style="fill:{colour}" transform="translate('
            f'{x + (w - box) / 2:g},{y + (h - box) / 2:g}) scale({box / size:g}) '
            f'translate({-vx:g},{-vy:g})" d="{d}"/>\n')
    return base.replace("</svg>", path + "</svg>")


def main():
    for entry in os.listdir(HERE):
        path = os.path.join(HERE, entry)
        if os.path.isdir(path):
            shutil.rmtree(path)

    symbolic = os.path.join(HERE, "symbolic/places")
    os.makedirs(symbolic)
    for gtk, name in ICONS.items():
        svg = material(name)
        svg = svg.replace('width="48" height="48"', 'width="16" height="16"')
        with open(os.path.join(symbolic, f"{gtk}-symbolic.svg"), "w") as f:
            f.write(svg)

    # 16x16 places are flat single-colour icons, and the @2x dirs link to
    # the bigger sizes
    dirs = set()
    glyphs = {gtk: material(name) for gtk, name in FOLDERS.items()}
    for root, _, files in os.walk(PAPIRUS):
        rel = os.path.relpath(root, PAPIRUS)
        if not rel.endswith("/places") or rel.startswith("16x16") or "@" in rel:
            continue
        for gtk, glyph in glyphs.items():
            if "folder.svg" in files:
                os.makedirs(os.path.join(HERE, rel), exist_ok=True)
                with open(os.path.join(HERE, rel, f"{gtk}.svg"), "w") as f:
                    f.write(folder_icon(rel, glyph))
                dirs.add(rel)

    # GTK tries every name of an icon (folder, ..., folder-symbolic) in this
    # theme before Papirus, so without these the main views would pick up
    # the symbolic sidebar icons
    for root, _, files in os.walk(PAPIRUS):
        rel = os.path.relpath(root, PAPIRUS)
        if "symbolic" in rel or "@" in rel:
            continue
        for gtk in ICONS:
            if f"{gtk}.svg" in files and not os.path.exists(
                    os.path.join(HERE, rel, f"{gtk}.svg")):
                os.makedirs(os.path.join(HERE, rel), exist_ok=True)
                os.symlink(os.path.join(root, f"{gtk}.svg"),
                           os.path.join(HERE, rel, f"{gtk}.svg"))
                dirs.add(rel)

    def size_key(d):
        size, context = d.split("/")
        return int(size.split("x")[0]), context

    dirs = sorted(dirs, key=size_key)
    index = open(os.path.join(PAPIRUS, "index.theme")).read()
    sections = {m.group(1): m.group(0).strip() for m in
                re.finditer(r"^\[([^\]]+)\]\n(?:(?!\[).*\n?)*", index, re.M)}
    with open(os.path.join(HERE, "index.theme"), "w") as f:
        f.write(HEADER.format(dirs=",".join(["symbolic/places"] + dirs)))
        f.write("\n" + "\n\n".join(sections[d] for d in dirs) + "\n")


if __name__ == "__main__":
    main()
