"""Builds map_3360x945.ui for the map-stats-test mod from the current 32:9 map file.

Usage:  python make.py <path to mods/32x9-ui/32_9-nsf/map_3360x945.ui> <out map_3360x945.ui> [key.png]
Adds a 4 x 6 grid of simple_text objects to the empty part of the bottom panel (x 2200..3088, y 838..932).
Each cell is bound to one candidate field name. A cell that shows a value = the engine fills that field on the map.
"""
import sys

X0, DX, W = 2200, 148, 144
Y0, DY, H = 838, 24, 22

GRID = [
    # row 0: controls, fields the map already shows (must display values)
    ["map_money", "map_rage", "map_mana", "map_level", "map_ldrshp", "map_hero_name"],
    # row 1: guesses in the same map_* family
    ["map_attack", "map_defense", "map_intellect", "map_crystals", "map_exp", "map_day"],
    # row 2: names the hero window binds (cross-form lookup?)
    ["hero_attack", "hero_defense", "hero_intellect", "hero_cryst", "hero_money", "hero_ldrshp"],
    # row 3: statistics names from records.ui
    ["rec_battle_num", "rec_enemy_killed", "rec_quest", "rec_money", "rec_level", "rec_body_count"],
]


def block(name, x0, y0, x1, y1):
    return ["gui_object_begin simple_text",
            "gui_object_position %d %d %d %d" % (x0, y0, x1, y1),
            'gui_object_name "kb26_%s"' % name,
            "gui_object_frigid 1",
            'gui_object_text "" "%s" 0.010000 0.990000 0.010000 0.990000' % name,
            "gui_object_end"]


def build(src, dst):
    raw = open(src, newline="", encoding="latin-1").read()
    lines = raw.replace("\r\n", "\n").split("\n")
    while lines and lines[-1] == "":
        lines.pop()
    assert lines[-1].strip() == "gui_end", "last line is not gui_end"
    add = []
    for r, row in enumerate(GRID):
        for c, name in enumerate(row):
            x = X0 + c * DX
            y = Y0 + r * DY
            add += block(name, x, y, x + W, y + H)
    # z-order in .ui files: the FIRST objects are drawn on top, the last ones are the background
    # (text fields such as map_money sit at the top of the file, panel pictures near the end).
    # So the new texts go right after gui_begin, otherwise the panel would hide them.
    assert lines[0].startswith("gui_begin")
    out = [lines[0]] + add + lines[1:]
    open(dst, "w", newline="", encoding="latin-1").write("\r\n".join(out) + "\r\n")
    return len(add) // 6


def key_png(path):
    from PIL import Image, ImageDraw, ImageFont
    cw, ch = 230, 46
    img = Image.new("RGB", (cw * 6 + 20, ch * 4 + 70), (30, 30, 36))
    d = ImageDraw.Draw(img)
    try:
        f = ImageFont.truetype("DejaVuSans.ttf", 15)
        fb = ImageFont.truetype("DejaVuSans-Bold.ttf", 17)
    except OSError:
        f = fb = ImageFont.load_default()
    d.text((10, 8), "map-stats-test: which cell shows a number? (row = line from top, col = left to right)", font=fb, fill=(240, 220, 150))
    titles = ["row 1: controls (must show)", "row 2: map_* guesses", "row 3: hero_* names", "row 4: rec_* statistics"]
    for r, row in enumerate(GRID):
        d.text((10, 36 + r * ch), titles[r], font=f, fill=(150, 200, 255))
        for c, name in enumerate(row):
            x, y = 10 + c * cw, 56 + r * ch
            d.rectangle([x, y, x + cw - 6, y + 24], outline=(120, 120, 130))
            d.text((x + 6, y + 3), "%d.%d %s" % (r + 1, c + 1, name), font=f, fill=(235, 235, 235))
    img.save(path)


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    n = build(sys.argv[1], sys.argv[2])
    print("added %d text objects" % n)
    if len(sys.argv) > 3:
        key_png(sys.argv[3]); print("key image:", sys.argv[3])
