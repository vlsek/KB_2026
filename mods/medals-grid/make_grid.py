"""Builds the compact 32:9 hero window with an 18-slot medals grid to the right of it (agent 4).

  python make_grid.py [hero.ui source] [out dir]
Source defaults to ../medal-slots-ui/hero.ui (Legend hero.ui + slots slot_13..18; more slots are cloned from slot_13).
Writes: hero_3360x945.ui, medals_grid_bg.png, rus_hero_append.txt (UTF-8, hover texts: one key kb26_med_N per slot).

Differences from mods/medals-panel (agent 2): compact slots (no side text), 6 columns x 3 rows = 18 slots,
the text of each family is shown on hover (gui_object_hint -> rus_hero.lng key), not drawn beside the slot.
The hero window itself is shifted like in medals-panel (DX, DY) so it sits in the middle of 3360x945.
"""
import csv, os, re, sys

W, H = 3360, 945
DX, DY = 1040, -8
N = 18
COLS = 6
SLOT = 48
GAP = 10
PAD = 16
TITLE_H = 42
PX = DX + 1280 + 20
PY = 60
ROWS = (N + COLS - 1) // COLS
PW = PAD * 2 + COLS * SLOT + (COLS - 1) * GAP
PH = TITLE_H + PAD + ROWS * SLOT + (ROWS - 1) * GAP + PAD
HERE = os.path.dirname(os.path.abspath(__file__))


def families():
    path = os.path.join(HERE, "..", "..", "docs", "achievements_legend.csv")
    rows = list(csv.DictReader(open(path, encoding="utf-8-sig")))
    return rows[:N]


def hint_text(r):
    ranks = [r[k].strip() for k in ("rank1", "rank2", "rank3", "rank4") if r[k].strip()]
    return "%s. %s: %s. Здесь появится медаль." % (r["name_ru"], r["condition_ru"], " / ".join(ranks))


def slot_pos(i):
    c, r = i % COLS, i // COLS
    x = PX + PAD + c * (SLOT + GAP)
    y = PY + TITLE_H + PAD + r * (SLOT + GAP)
    return x, y, x + SLOT, y + SLOT


def build_ui(src, dst):
    raw = open(src, newline="", encoding="latin-1").read()
    nl = "\r\n" if "\r\n" in raw else "\n"
    lines = raw.replace("\r\n", "\n").split("\n")
    out, i, shifted = [], 0, 0
    slot_tpl = None
    names = ["slot_%d" % (13 + k) for k in range(N)]
    seen = set()
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
            if name in names:
                if slot_tpl is None:
                    slot_tpl = list(block)
                k = names.index(name)
                seen.add(name)
                x0, y0, x1, y1 = slot_pos(k)
                nb = []
                for b in block:
                    if b.startswith("gui_object_position"):
                        b = "gui_object_position %d %d %d %d" % (x0, y0, x1, y1)
                    elif b.startswith("gui_object_hint"):
                        b = 'gui_object_hint "rus_hero.lng" "kb26_med_%d"' % (k + 1)
                    nb.append(b)
                out += nb
            else:
                for k, b in enumerate(block):
                    if b.startswith("gui_object_position"):
                        x0, y0, x1, y1 = map(int, b.split()[1:5])
                        block[k] = "gui_object_position %d %d %d %d" % (x0 + DX, y0 + DY, x1 + DX, y1 + DY)
                        shifted += 1
                out += block
            i = j + 1
            continue
        out.append(ln)
        i += 1
    assert slot_tpl is not None, "slot_13 not found in the source hero.ui"
    extra = []
    for k, name in enumerate(names):
        if name in seen:
            continue
        x0, y0, x1, y1 = slot_pos(k)
        for b in slot_tpl:
            if b.startswith("gui_object_position"):
                b = "gui_object_position %d %d %d %d" % (x0, y0, x1, y1)
            elif b.startswith("gui_object_name"):
                b = 'gui_object_name "%s"' % name
            elif b.startswith("gui_object_hint"):
                b = 'gui_object_hint "rus_hero.lng" "kb26_med_%d"' % (k + 1)
            extra.append(b)
    end = max(k for k, l in enumerate(out) if l.strip() == "gui_end")
    bg = ["gui_object_begin picture", 'gui_object_picture "medals_grid_bg.png"', "gui_object_picture_angle 0.000000 0",
          "gui_object_position %d %d %d %d" % (PX, PY, PX + PW, PY + PH), 'gui_object_name "medals_grid_bg"',
          "gui_object_frigid 1", "gui_object_end"]
    out[end:end] = extra + bg
    open(dst, "w", newline="", encoding="latin-1").write(nl.join(out))
    return shifted, len(names) - len(seen)


def build_png(dst):
    from PIL import Image, ImageDraw, ImageFont
    S = 2
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
    f_title = font("DejaVuSerif-Bold.ttf", 18)
    gold, gold_d = (201, 160, 72), (112, 84, 36)
    for y in range(PH * S):
        t = y / (PH * S)
        d.line([(0, y), (PW * S, y)], fill=(int(46 - 14 * t), int(36 - 12 * t), int(28 - 10 * t), 244))
    d.rectangle([0, 0, PW * S - 1, PH * S - 1], outline=gold, width=3 * S)
    d.rectangle([4 * S, 4 * S, PW * S - 5 * S, PH * S - 5 * S], outline=gold_d, width=1 * S)
    tw = d.textlength("НАГРАДЫ", font=f_title)
    d.text(((PW * S - tw) / 2, 10 * S), "НАГРАДЫ", font=f_title, fill=gold)
    d.line([(20 * S, (TITLE_H - 4) * S), ((PW - 20) * S, (TITLE_H - 4) * S)], fill=gold_d, width=1 * S)
    for k in range(N):
        x0, y0, x1, y1 = slot_pos(k)
        sx, sy = x0 - PX, y0 - PY
        d.rounded_rectangle([(sx - 3) * S, (sy - 3) * S, (sx + SLOT + 3) * S, (sy + SLOT + 3) * S], radius=4 * S,
                            fill=(20, 15, 11, 255), outline=gold_d, width=2 * S)
    img.resize((PW, PH), Image.LANCZOS).save(dst)


def write_texts(dst):
    lines = ["kb26_med_%d=%s" % (k + 1, hint_text(r)) for k, r in enumerate(families())]
    open(dst, "w", encoding="utf-8", newline="").write("\r\n".join(lines) + "\r\n")


if __name__ == "__main__":
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "medal-slots-ui", "hero.ui")
    out = sys.argv[2] if len(sys.argv) > 2 else HERE
    s, cloned = build_ui(src, os.path.join(out, "hero_3360x945.ui"))
    build_png(os.path.join(out, "medals_grid_bg.png"))
    write_texts(os.path.join(out, "rus_hero_append.txt"))
    print("shifted %d objects; %d slots cloned; grid %dx%d at x %d..%d y %d..%d" % (s, cloned, COLS, ROWS, PX, PX + PW, PY, PY + PH))
