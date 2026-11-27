"""medals-book (agent 5): the 18-medal panel in the style of the game: gold frame, vines, a plaque with the title,
18 cards (slot + name + condition + ranks UNDER the slot).

  python make_book.py [hero.ui source] [out dir]
Needs Pillow. Reuses build_ui() of ../medals-grid/make_grid.py (shifted 32:9 hero window, slots 13..30) with a new layout.
Writes: hero_3360x945.ui, medals_book_bg.png (panel art, text is baked in), rus_hero_append.txt, preview.png.
The text under the slots is part of the PNG: change docs/achievements_legend.csv and run the script again.
"""
import csv, math, os, random, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "medals-grid"))
import make_grid as mg

N, COLS = 18, 6
ROWS = (N + COLS - 1) // COLS
SLOT = 56
CELL_W, CELL_H, GX, GY = 150, 164, 6, 6
PAD = 36            # ring for the frame and vines
HEAD = 66           # plaque with the title
FOOT = 46
PW = PAD * 2 + COLS * CELL_W + (COLS - 1) * GX
PH = HEAD + ROWS * CELL_H + (ROWS - 1) * GY + FOOT + PAD // 2
PX, PY = mg.DX + 1280 + 20, 30
S = 3  # supersampling

FONT_DIR = "/usr/share/fonts/truetype/"
FONTS = {
    "title": ["google-fonts/Lora-Variable.ttf", "dejavu/DejaVuSerif-Bold.ttf"],
    "name": ["google-fonts/Lora-Variable.ttf", "dejavu/DejaVuSerif-Bold.ttf"],
    "text": ["google-fonts/Lora-Variable.ttf", "dejavu/DejaVuSerif.ttf"],
    "ital": ["google-fonts/Lora-Italic-Variable.ttf", "dejavu/DejaVuSerif-Italic.ttf"],
}

GOLD_L, GOLD, GOLD_D, GOLD_DD = (236, 206, 122), (201, 160, 72), (130, 96, 40), (62, 44, 20)
LEAF_D, LEAF_M, LEAF_L, LEAF_O = (30, 52, 24), (58, 96, 42), (112, 150, 74), (16, 28, 12)
PARCH = (232, 214, 168)


def families():
    path = os.path.join(HERE, "..", "..", "docs", "achievements_legend.csv")
    return list(csv.DictReader(open(path, encoding="utf-8-sig")))[:N]


def short_num(v):
    v = int(v)
    if v >= 1000000 and v % 1000000 == 0:
        return "%d\u041c" % (v // 1000000)       # 1M
    if v >= 1000 and v % 1000 == 0:
        return "%d\u043a" % (v // 1000)          # 5k
    return str(v)


def clean_condition(s):
    return re.sub(r"\s*\([^)]*\)\s*$", "", s.strip()) if re.search(r"\([a-z_]+\)\s*$", s) else s.strip()


def cell_origin(k):
    c, r = k % COLS, k // COLS
    return PAD + c * (CELL_W + GX), HEAD + r * (CELL_H + GY)


def slot_pos(k):
    cx, cy = cell_origin(k)
    x = PX + cx + (CELL_W - SLOT) // 2
    y = PY + cy + 10
    return x, y, x + SLOT, y + SLOT


# ---------------------------------------------------------------- drawing helpers
def load_font(kind, size):
    from PIL import ImageFont
    for p in FONTS[kind]:
        try:
            f = ImageFont.truetype(FONT_DIR + p, size * S)
            try:
                f.set_variation_by_axes([700 if kind in ("title", "name") else 450])
            except Exception:
                pass
            return f
        except OSError:
            pass
    return ImageFont.load_default()


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def bezier(p0, p1, p2, p3, n=60):
    pts = []
    for i in range(n + 1):
        t = i / n
        u = 1 - t
        pts.append((u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
                    u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1]))
    return pts


def draw_stroke(d, pts, w, color):
    r = w * S / 2.0
    for (x, y) in pts:
        d.ellipse([x * S - r, y * S - r, x * S + r, y * S + r], fill=color)


def draw_leaf(d, x, y, ang, L, W):
    """one leaf: two-tone with a vein; (x, y) is the base, ang in radians"""
    n = 18
    left, right = [], []
    for i in range(n + 1):
        t = i / n
        w = W * (math.sin(math.pi * t) ** 0.85) * (1 - 0.25 * t)
        px, py = t * L, 0
        left.append((px, -w / 2))
        right.append((px, w / 2))
    def tr(p):
        c, s = math.cos(ang), math.sin(ang)
        return ((x + p[0] * c - p[1] * s) * S, (y + p[0] * s + p[1] * c) * S)
    outline = [tr(p) for p in left] + [tr(p) for p in reversed(right)]
    d.polygon(outline, fill=LEAF_M, outline=LEAF_O)
    d.polygon([tr(p) for p in left] + [tr((p[0], 0)) for p in reversed(left)], fill=LEAF_L)
    d.line([tr((0, 0)), tr((L * 0.92, 0))], fill=LEAF_D, width=max(1, int(S * 0.9)))


def draw_curl(d, x, y, ang, r0, turns=1.6, sgn=1):
    pts = []
    n = 30
    for i in range(n + 1):
        t = i / n
        a = ang + sgn * t * turns * 2 * math.pi
        r = r0 * (1 - 0.82 * t)
        cx = x + r * math.cos(a)
        cy = y + r * math.sin(a)
        pts.append((cx, cy))
    draw_stroke(d, pts, 1.6, LEAF_O)
    draw_stroke(d, pts, 1.0, LEAF_M)


def vine_along(d, pts, rnd, leaf_every=22, leaf_len=(12, 19), side0=1, width=3.6, curls=True):
    """thick vine over pts with leaves on alternating sides and tendrils"""
    draw_stroke(d, pts, width + 1.6, LEAF_O)
    draw_stroke(d, pts, width, LEAF_D)
    draw_stroke(d, [(x - 0.5, y - 0.6) for x, y in pts], width * 0.45, LEAF_M)
    acc, side = 0.0, side0
    for i in range(1, len(pts) - 1):
        acc += math.hypot(pts[i][0] - pts[i - 1][0], pts[i][1] - pts[i - 1][1])
        if acc >= leaf_every:
            acc = 0.0
            tx, ty = pts[i + 1][0] - pts[i - 1][0], pts[i + 1][1] - pts[i - 1][1]
            a = math.atan2(ty, tx) + side * math.radians(rnd.uniform(40, 70))
            L = rnd.uniform(*leaf_len)
            draw_leaf(d, pts[i][0], pts[i][1], a, L, L * rnd.uniform(0.42, 0.55))
            if curls and rnd.random() < 0.28:
                draw_curl(d, pts[i][0] + 2 * math.cos(a), pts[i][1] + 2 * math.sin(a), a, rnd.uniform(4, 6), sgn=side)
            side = -side


def wave(p0, p1, amp, waves, n=90):
    pts = []
    dx, dy = p1[0] - p0[0], p1[1] - p0[1]
    L = math.hypot(dx, dy)
    nx, ny = -dy / L, dx / L
    for i in range(n + 1):
        t = i / n
        o = amp * math.sin(t * waves * 2 * math.pi) * (0.55 + 0.45 * math.sin(t * math.pi))
        pts.append((p0[0] + dx * t + nx * o, p0[1] + dy * t + ny * o))
    return pts


def bevel_rect(d, box, th, light, mid, dark):
    x0, y0, x1, y1 = [v * S for v in box]
    for i in range(int(th * S)):
        t = i / (th * S)
        c = lerp(light, dark, abs(t - 0.35) * 1.4) if t > 0.35 else lerp(dark, light, t / 0.35)
        d.rectangle([x0 + i, y0 + i, x1 - i, y1 - i], outline=c, width=1)


def draw_corner(d, x, y, sx, sy):
    """gold corner bracket with a rivet and two small leaves; (sx, sy) = +-1 direction into the panel"""
    L = 40
    for k, col, w in ((0, GOLD_DD, 7), (1, GOLD, 5), (2, GOLD_L, 1.6)):
        off = k * 0.6
        d.line([(x * S, (y + off * sy) * S), ((x + L * sx) * S, (y + off * sy) * S)], fill=col, width=int(w * S))
        d.line([((x + off * sx) * S, y * S), ((x + off * sx) * S, (y + L * sy) * S)], fill=col, width=int(w * S))
    cx, cy = x + 9 * sx, y + 9 * sy
    for r, col in ((8, GOLD_DD), (6.5, GOLD), (4.5, GOLD_L), (2.2, GOLD_D)):
        d.ellipse([(cx - r) * S, (cy - r) * S, (cx + r) * S, (cy + r) * S], fill=col)
    for a in (math.radians(20), math.radians(70)):
        ax = math.atan2(sy, sx)
        draw_leaf(d, cx + 6 * sx, cy + 6 * sy, ax + (a - math.radians(45)) * 1.2, 15, 7)


def draw_diamond(d, cx, cy, r, fill, outline):
    d.polygon([(cx * S, (cy - r) * S), ((cx + r) * S, cy * S), (cx * S, (cy + r) * S), ((cx - r) * S, cy * S)], fill=fill, outline=outline)


def wrap(d, text, font, maxw):
    words, lines, cur = text.split(), [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if d.textlength(t, font=font) <= maxw * S or not cur:
            cur = t
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def text_center(d, cx, y, s, font, fill, shadow=(0, 0, 0, 200)):
    w = d.textlength(s, font=font)
    x = cx * S - w / 2
    if shadow:
        d.text((x + 1.2 * S, y * S + 1.2 * S), s, font=font, fill=shadow)
    d.text((x, y * S), s, font=font, fill=fill)


# ---------------------------------------------------------------- the panel
def build_png(dst, fams):
    from PIL import Image, ImageDraw, ImageFilter
    rnd = random.Random(26)
    W, H = PW * S, PH * S
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # leather / parchment-dark background with a soft vignette and grain
    for y in range(H):
        t = y / H
        d.line([(0, y), (W, y)], fill=(int(54 - 16 * t), int(40 - 13 * t), int(29 - 10 * t), 248))
    grain = Image.effect_noise((W // 2, H // 2), 28).resize((W, H)).convert("L").point(lambda v: int(v * 0.16))
    img.paste(Image.new("RGBA", (W, H), (255, 236, 190, 255)), (0, 0), grain)
    d = ImageDraw.Draw(img)
    vg = Image.new("L", (W, H), 0)
    vd = ImageDraw.Draw(vg)
    vd.rectangle([PAD * S, PAD * S, W - PAD * S, H - PAD * S], fill=150)
    vg = vg.filter(ImageFilter.GaussianBlur(40 * S))
    shade = Image.new("RGBA", (W, H), (8, 5, 3, 255))
    shade.putalpha(vg.point(lambda v: 150 - v))
    img.alpha_composite(shade)
    d = ImageDraw.Draw(img)

    # frame: outer dark line, gold bevel, inner dark line
    d.rectangle([0, 0, W - 1, H - 1], outline=GOLD_DD, width=2 * S)
    bevel_rect(d, (3, 3, PW - 4, PH - 4), 7, GOLD_L, GOLD, GOLD_DD)
    d.rectangle([11 * S, 11 * S, W - 11 * S, H - 11 * S], outline=GOLD_DD, width=2 * S)
    d.rectangle([13 * S, 13 * S, W - 13 * S, H - 13 * S], outline=GOLD_D, width=1 * S)

    # vines in the ring between the frame and the cards (kept off the text)
    ring = 22
    vine_along(d, wave((ring, PH - ring), (ring, ring + 20), 4.5, 6), rnd, leaf_every=15, side0=1)
    vine_along(d, wave((PW - ring, PH - ring), (PW - ring, ring + 20), 4.5, 6), rnd, leaf_every=15, side0=-1)
    vine_along(d, wave((ring + 14, PH - ring + 6), (PW - ring - 14, PH - ring + 6), 3.5, 20), rnd, leaf_every=18, side0=-1, width=3.0)
    vine_along(d, wave((ring + 14, ring + 12), (PW // 2 - 118, ring + 8), 3.2, 4), rnd, leaf_every=16, side0=1, width=3.0)
    vine_along(d, wave((PW - ring - 14, ring + 12), (PW // 2 + 118, ring + 8), 3.2, 4), rnd, leaf_every=16, side0=-1, width=3.0)

    # gold corners over the vines
    for (x, y, sx, sy) in ((3, 3, 1, 1), (PW - 4, 3, -1, 1), (3, PH - 4, 1, -1), (PW - 4, PH - 4, -1, -1)):
        draw_corner(d, x, y, sx, sy)

    # title plaque
    f_title = load_font("title", 22)
    cxm = PW / 2
    pw_, ph_ = 250, 40
    px0, py0 = cxm - pw_ / 2, 20
    for off, col in ((3, GOLD_DD), (1.5, GOLD), (0, GOLD_L)):
        d.rounded_rectangle([(px0 - off) * S, (py0 - off) * S, (px0 + pw_ + off) * S, (py0 + ph_ + off) * S],
                            radius=10 * S, outline=col, width=2 * S)
    d.rounded_rectangle([px0 * S, py0 * S, (px0 + pw_) * S, (py0 + ph_) * S], radius=9 * S, fill=(30, 21, 14, 255))
    for sgn in (-1, 1):
        draw_diamond(d, cxm + sgn * (pw_ / 2 + 14), py0 + ph_ / 2, 6, GOLD, GOLD_DD)
        draw_diamond(d, cxm + sgn * (pw_ / 2 + 28), py0 + ph_ / 2, 3.5, GOLD_D, GOLD_DD)
    text_center(d, cxm, py0 + 3, "\u041c\u0415\u0414\u0410\u041b\u0418", f_title, GOLD_L)
    # divider under the plaque
    yd = HEAD - 6
    d.line([(PAD * S, yd * S), ((cxm - 12) * S, yd * S)], fill=GOLD_D, width=S)
    d.line([((cxm + 12) * S, yd * S), ((PW - PAD) * S, yd * S)], fill=GOLD_D, width=S)
    draw_diamond(d, cxm, yd, 5, GOLD, GOLD_DD)

    # cards
    f_name = load_font("name", 13)
    f_text = load_font("text", 12)
    f_rank = load_font("ital", 12)
    for k, r in enumerate(fams):
        cx, cy = cell_origin(k)
        x0, y0, x1, y1 = cx, cy, cx + CELL_W, cy + CELL_H
        d.rounded_rectangle([x0 * S, y0 * S, x1 * S, y1 * S], radius=7 * S, fill=(26, 18, 11, 175), outline=GOLD_DD, width=2 * S)
        d.rounded_rectangle([(x0 + 1.5) * S, (y0 + 1.5) * S, (x1 - 1.5) * S, (y1 - 1.5) * S], radius=6 * S, outline=(120, 90, 44, 130), width=S)
        # slot well (the native slot button is drawn over it by the game)
        sx0, sy0 = cx + (CELL_W - SLOT) // 2, cy + 10
        d.rounded_rectangle([(sx0 - 5) * S, (sy0 - 5) * S, (sx0 + SLOT + 5) * S, (sy0 + SLOT + 5) * S], radius=6 * S,
                            fill=(16, 11, 8, 255), outline=GOLD_D, width=2 * S)
        d.rounded_rectangle([(sx0 - 2) * S, (sy0 - 2) * S, (sx0 + SLOT + 2) * S, (sy0 + SLOT + 2) * S], radius=4 * S, outline=(0, 0, 0, 220), width=S)
        # texts under the slot
        ty = sy0 + SLOT + 9
        mid = cx + CELL_W / 2
        name_lines = wrap(d, r["name_ru"], f_name, CELL_W - 14)[:2]
        for ln in name_lines:
            text_center(d, mid, ty, ln, f_name, GOLD_L)
            ty += 15.5
        d.line([((mid - 26) * S, (ty + 1) * S), ((mid + 26) * S, (ty + 1) * S)], fill=(150, 112, 52, 170), width=S)
        ty += 5
        cond = clean_condition(r["condition_ru"])
        for ln in wrap(d, cond, f_text, CELL_W - 14)[:3]:
            text_center(d, mid, ty, ln, f_text, PARCH)
            ty += 13
        ranks = [r[q].strip() for q in ("rank1", "rank2", "rank3", "rank4") if r[q].strip()]
        rl = wrap(d, " \u00b7 ".join(short_num(v) for v in ranks), f_rank, CELL_W - 14)[:2]
        ty = max(ty + 2, y1 - 6 - 13 * len(rl))
        for ln in rl:
            text_center(d, mid, ty, ln, f_rank, GOLD)
            ty += 13

    # footer line
    f_foot = load_font("ital", 12)
    text_center(d, cxm, PH - PAD // 2 - 34, "\u041c\u0435\u0434\u0430\u043b\u0438 \u0432\u044b\u0434\u0430\u044e\u0442\u0441\u044f \u0430\u0432\u0442\u043e\u043c\u0430\u0442\u0438\u0447\u0435\u0441\u043a\u0438, \u043f\u043e\u0432\u044b\u0448\u0430\u044f \u0440\u0430\u043d\u0433 \u0437\u0430 \u0434\u043e\u0441\u0442\u0438\u0436\u0435\u043d\u0438\u044f", f_foot, (170, 140, 90), shadow=(0, 0, 0, 160))

    out = img.resize((PW, PH), Image.LANCZOS)
    out.save(dst)
    return out


def build_ui(src, dst):
    mg.PX, mg.PY, mg.PW, mg.PH = PX, PY, PW, PH
    mg.N, mg.COLS, mg.SLOT = N, COLS, SLOT
    mg.slot_pos = slot_pos
    shifted, cloned = mg.build_ui(src, dst)
    raw = open(dst, newline="", encoding="latin-1").read()
    nl = "\r\n" if "\r\n" in raw else "\n"
    raw = raw.replace("medals_grid_bg", "medals_book_bg")
    lines = raw.replace("\r\n", "\n").split("\n")
    # z-order: the panel art goes FIRST in the file (drawn under every slot and under the hero window)
    i = next(k for k, l in enumerate(lines) if l.startswith("gui_object_begin picture") and 'medals_book_bg' in "".join(lines[k:k + 3]))
    j = i
    while lines[j].strip() != "gui_object_end":
        j += 1
    block = lines[i:j + 1]
    del lines[i:j + 1]
    first = next(k for k, l in enumerate(lines) if l.startswith("gui_object_begin"))
    lines[first:first] = block
    open(dst, "w", newline="", encoding="latin-1").write(nl.join(lines))
    return shifted, cloned


def write_texts(dst, fams):
    def hint(r):
        ranks = [r[k].strip() for k in ("rank1", "rank2", "rank3", "rank4") if r[k].strip()]
        return "%s. %s: %s." % (r["name_ru"], clean_condition(r["condition_ru"]), " / ".join(ranks))
    lines = ["kb26_med_%d=%s" % (k + 1, hint(r)) for k, r in enumerate(fams)]
    open(dst, "w", encoding="utf-8", newline="").write("\r\n".join(lines) + "\r\n")


if __name__ == "__main__":
    src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(HERE, "..", "medal-slots-ui", "hero.ui")
    out = sys.argv[2] if len(sys.argv) > 2 else HERE
    fams = families()
    s, c = build_ui(src, os.path.join(out, "hero_3360x945.ui"))
    png = build_png(os.path.join(out, "medals_book_bg.png"), fams)
    write_texts(os.path.join(out, "rus_hero_append.txt"), fams)
    # preview: the panel on a dark backdrop with the slot rectangles as the game will draw them
    from PIL import Image, ImageDraw
    pv = Image.new("RGBA", (PW + 40, PH + 40), (18, 16, 18, 255))
    pv.alpha_composite(png, (20, 20))
    dd = ImageDraw.Draw(pv)
    for k in range(N):
        x0, y0, x1, y1 = slot_pos(k)
        dd.rectangle([x0 - PX + 20, y0 - PY + 20, x1 - PX + 20 - 1, y1 - PY + 20 - 1], outline=(90, 150, 230, 255), width=1)
    pv.convert("RGB").save(os.path.join(out, "preview.png"))
    print("shifted %d; cloned %d; panel %dx%d at x %d..%d y %d..%d" % (s, c, PW, PH, PX, PX + PW, PY, PY + PH))
