#!/usr/bin/env python3
"""Rebuild Material-Papirus: Material Symbols (Rounded, filled) for the GTK
file manager sidebar icons, everything else inherited from Papirus.

Add a sidebar icon by adding a line to ICONS and running ./build.py.
Material names: https://fonts.google.com/icons
"""
import os
import re
import shutil
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
PAPIRUS = "/usr/share/icons/Papirus"
CDN = "https://cdn.jsdelivr.net/npm/@material-symbols/svg-400@0.48.1/rounded"

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

HEADER = """[Icon Theme]
Name=Material-Papirus
Comment=Papirus, with Material Symbols (Rounded, filled) for the file manager sidebar icons
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


def main():
    for entry in os.listdir(HERE):
        path = os.path.join(HERE, entry)
        if os.path.isdir(path):
            shutil.rmtree(path)

    symbolic = os.path.join(HERE, "symbolic/places")
    os.makedirs(symbolic)
    for gtk, material in ICONS.items():
        with urllib.request.urlopen(f"{CDN}/{material}-fill.svg") as r:
            svg = r.read().decode()
        svg = svg.replace('width="48" height="48"', 'width="16" height="16"')
        with open(os.path.join(symbolic, f"{gtk}-symbolic.svg"), "w") as f:
            f.write(svg)

    # GTK tries every name of an icon (folder, ..., folder-symbolic) in this
    # theme before Papirus, so without these the main views would pick up
    # the symbolic sidebar icons
    dirs = set()
    for root, _, files in os.walk(PAPIRUS):
        rel = os.path.relpath(root, PAPIRUS)
        if "symbolic" in rel or "@" in rel:
            continue
        for gtk in ICONS:
            if f"{gtk}.svg" in files:
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
