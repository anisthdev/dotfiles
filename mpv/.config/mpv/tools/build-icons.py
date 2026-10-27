#!/usr/bin/env python3
# Builds fonts/material-symbols-mpv.ttf, the player's icon font: Material Symbols Rounded
# (https://github.com/google/material-design-icons, variablefont/) pinned to the filled
# style and cut down to the icons listed in icons.txt. Icons are drawn by name through
# ligatures, e.g. "skip_next". The family is renamed so it never clashes with a system copy.
#
# Usage: build-icons.py 'MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf' ../fonts/material-symbols-mpv.ttf
# Needs fonttools.

import os
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

FAMILY = 'material-symbols-mpv'
AXES = {'FILL': 1, 'wght': 400, 'GRAD': 0, 'opsz': 24}


def ligature_subtables(font):
	for lookup in font['GSUB'].table.LookupList.Lookup:
		for st in lookup.SubTable:
			st = getattr(st, 'ExtSubTable', st)
			if hasattr(st, 'ligatures'):
				yield st


def spell(font):
	"""Returns a function spelling a ligature back into its icon name."""
	rev = {}
	# Upper and lower case share glyphs; prefer lowercase
	for cp, glyph in sorted(font.getBestCmap().items(), reverse=True):
		rev.setdefault(glyph, chr(cp))

	def name(first, ligature):
		try:
			return rev[first] + ''.join(rev[c] for c in ligature.Component)
		except KeyError:
			return None

	return name


def main(src, out):
	list_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'icons.txt')
	with open(list_path) as f:
		wanted = {line.strip() for line in f if line.strip() and not line.startswith('#')}

	font = instancer.instantiateVariableFont(TTFont(src), AXES)
	name = spell(font)

	# Keep only the wanted ligatures, so the subsetter's closure doesn't pull in every icon
	found, outputs = set(), set()
	for st in ligature_subtables(font):
		kept = {}
		for first, ligatures in st.ligatures.items():
			keep = [l for l in ligatures if name(first, l) in wanted]
			if keep:
				kept[first] = keep
				for l in keep:
					found.add(name(first, l))
					outputs.add(l.LigGlyph)
		st.ligatures = kept

	missing = sorted(wanted - found)
	if missing:
		sys.exit('not in Material Symbols: ' + ', '.join(missing))

	options = subset.Options()
	options.layout_features = ['rlig', 'liga', 'rclt']
	options.glyph_names = True
	options.name_IDs = list(range(26))
	subsetter = subset.Subsetter(options)
	subsetter.populate(glyphs=sorted(outputs), text='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_')
	subsetter.subset(font)

	for record in font['name'].names:
		if record.nameID in (1, 3, 4, 6, 16):
			record.string = FAMILY
	font.save(out)
	print(f'{out}: {len(found)} icons')


if __name__ == '__main__':
	main(*sys.argv[1:3])
