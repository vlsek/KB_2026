"""Builds the 32:9 hero window with a medals panel to the right of it.

  python make_panel.py [hero.ui source] [out dir]
Source defaults to ../medal-slots-ui/hero.ui (the Legend hero.ui + slot_13..18).
Writes: hero_3360x945.ui (explicit 3360x945 window, like the quests journal) and medals_panel_bg.png.

How: every object of the 1280x960 hero window is shifted by (DX, DY) so the window sits in the middle of the screen;
the six medal slots slot_13..18 are taken out of the window and placed into a panel to the right of it;
the panel background (our own PNG, no game art) is added as the last (= bottom) object.
"""
import os
import re
import sys

W, H = 3360, 945
DX, DY = 1040, -8            # (3360-1280)/2 and (945-960)/2 rounded
PX = DX + 1280 + 20          # panel left edge: 20 px right of the hero window
PW = 430
ROW_H = 84
TITLE_H = 54
SLOT = 60

# (name, thresholds) - official Legend Steam thresholds, see docs/LEGEND_OFFICIAL_ACHIEVEMENTS.md. One row = one slot.
FAMILIES = [
    ("Золотой запас", "100 000 · 500 000 · 1 000 000"),
    ("Лидерство", "5 000 · 10 000 · 15 000 · 20 000"),
    ("Уровень героя", "10 · 20 · 30"),
    ("Мана", "50 · 75 · 100"),
    ("Ярость", "50 · 75 · 100"),
    ("Задания", "25 · 50 · 75 · 100"),
]
ROWS = len(FAMILIES)
PH = TITLE_H + ROWS * ROW_H + 14
PY = 60                      # top part of the screen: stays above the map bottom bar (y 696+)
SLOT_NAMES = ["slot_%d" % (13 + i) for i in range(ROWS)]   # slots 13..18 exist in the source hero.ui


def slot_pos(i):
    x = PX + 22
    y = PY + TITLE_H + i * ROW_H + (ROW_H - SLOT) // 2
    return x, y, x + SLOT, y + SLOT


def build_ui(src, dst):
    raw = open(src, newline="", encoding="latin-1").read()
    nl = "\r\n" if "\r\n" in raw else "\n"
    lines = raw.replace("\r\n", "\n").split("\n")
    out, i, shifted, moved = [], 0, 0, 0
    while i < len(lines):
        ln = lines[i]
        if ln.startswith("gui_begin"):
            out.append("gui_begin %d %d" % (W, H)); i += 1; continue
        if ln.startswith("gui_object_begin"):
            j = i
            while lines[j].strip() != "gui_object_end":
                j += 1
            block = lines[i:j + 1]
            name = next((b.split('"')[1] for b in block if b.startswith("gui_object_name")), "")
            for k, b in enumerate(block):
                if b.startswith("gui_object_position"):
                    x0, y0, x1, y1 = map(int, b.split()[1:5])
                    if name in SLOT_NAMES:
                        x0, y0, x1, y1 = slot_pos(SLOT_NAMES.index(name)); moved += 1
                    else:
                        x0, y0, x1, y1 = x0 + DX, y0 + DY, x1 + DX, y1 + DY; shifted += 1
                    block[k] = "gui_object_position %d %d %d %d" % (x0, y0, x1, y1)
            out += block; i = j + 1; continue
        out.append(ln); i += 1
    assert moved == ROWS, "expected %d slot objects, found %d" % (ROWS, moved)
    # panel background = bottom-most object: insert right before the closing gui_end
    end = max(k for k, l in enumerate(out) if l.strip() == "gui_end")
    bg = ["gui_object_begin picture", 'gui_object_picture "medals_panel_bg.png"', "gui_object_picture_angle 0.000000 0",
          "gui_object_position %d %d %d %d" % (PX, PY, PX + PW, PY + PH), 'gui_object_name "medals_panel_bg"',
          "gui_object_frigid 1", "gui_object_end"]
    out[end:end] = bg
    open(dst, "w", newline="", encoding="latin-1").write(nl.join(out))
    return shifted, moved


def build_png(dst):
    from PIL import Image, ImageDraw, ImageFont
    S = 2  # draw at 2x and shrink: smooth edges
    img = Image.new("RGBA", (PW * S, PH * S), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    fd = "/usr/share/fonts/truetype/dejavu/"
    def font(name, size):
        for p in (fd + name, name):
            try:
                return ImageFont.truetype(p, size * S)
            except OSError:
                pass
        return ImageFont.load_default()
    f_title, f_name, f_thr = font("DejaVuSerif-Bold.ttf", 22), font("DejaVuSerif-Bold.ttf", 17), font("DejaVuSans.ttf", 13)
    gold, gold_d, cream, tan = (201, 160, 72), (112, 84, 36), (240, 228, 196), (176, 160, 128)
    # body with vertical gradient
    for y in range(PH * S):
        t = y / (PH * S)
        c = (int(46 - 14 * t), int(36 - 12 * t), int(28 - 10 * t), 244)
        d.line([(0, y), (PW * S, y)], fill=c)
    d.rectangle([0, 0, PW * S - 1, PH * S - 1], outline=gold, width=3 * S)
    d.rectangle([5 * S, 5 * S, PW * S - 6 * S, PH * S - 6 * S], outline=gold_d, width=1 * S)
    # title
    tw = d.textlength("НАГРАДЫ", font=f_title)
    d.text(((PW * S - tw) / 2, 13 * S), "НАГРАДЫ", font=f_title, fill=gold)
    d.line([(24 * S, (TITLE_H - 6) * S), ((PW - 24) * S, (TITLE_H - 6) * S)], fill=gold_d, width=1 * S)
    for i, (name, thr) in enumerate(FAMILIES):
        y0 = TITLE_H + i * ROW_H
        sx, sy = 22, y0 + (ROW_H - SLOT) // 2
        # socket frame around the slot button (the button itself is drawn by the game)
        d.rounded_rectangle([(sx - 5) * S, (sy - 5) * S, (sx + SLOT + 5) * S, (sy + SLOT + 5) * S], radius=5 * S,
                            fill=(20, 15, 11, 255), outline=gold_d, width=2 * S)
        tx = sx + SLOT + 20
        d.text((tx * S, (y0 + 18) * S), name, font=f_name, fill=cream)
        d.text((tx * S, (y0 + 46) * S), thr, font=f_thr, fill=tan)
        if i < ROWS - 1:
            d.line([(18 * S, (y0 + ROW_H - 1) * S), ((PW - 18) * S, (y0 + ROW_H - 1) * S)], fill=(70, 55, 38, 255), width=1 * S)
    img = img.resize((PW, PH), Image.LANCZOS)
    img.save(dst)


if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "..", "medal-slots-ui", "hero.ui")
    out = sys.argv[2] if len(sys.argv) > 2 else here
    s, m = build_ui(src, os.path.join(out, "hero_3360x945.ui"))
    build_png(os.path.join(out, "medals_panel_bg.png"))
    print("shifted %d objects by (%d, %d), moved %d slots into the panel (x %d..%d, y %d..%d)" % (s, DX, DY, m, PX, PX + PW, PY, PY + PH))
