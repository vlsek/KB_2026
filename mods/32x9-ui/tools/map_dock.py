import sys
src, dst = sys.argv[1], sys.argv[2]
NEW_W, H = 3360, 945
LEFT_END, RIGHT_START = 244, 1240
DX_C, DX_R = 1182 - 244, NEW_W - 1680
def group(x): return "L" if x < LEFT_END else ("C" if x < RIGHT_START else "R")
dx = {"L": 0, "C": DX_C, "R": DX_R}

raw = open(src, newline="").read().replace("\r\n", "\n").split("\n")
# split into objects
head, objs, cur = [], [], None
for ln in raw:
    if ln.startswith("gui_object_begin"): cur = [ln]
    elif cur is not None:
        cur.append(ln)
        if ln.startswith("gui_object_end"): objs.append(cur); cur = None
    elif ln.startswith("gui_end"): tail = ln
    elif ln.startswith("gui_begin"): head.append(f"gui_begin {NEW_W} {H}")

def get(o, key):
    for i, l in enumerate(o):
        if l.startswith(key): return i, l
def pic(o):
    r = get(o, "gui_object_picture "); return r[1].split('"')[1] if r else ""
def name(o): return get(o, "gui_object_name")[1].split('"')[1]
def mk(picname, x0, x1, objname):
    return ["gui_object_begin picture", f'gui_object_picture "{picname}"', "gui_object_picture_angle 0.000000 0",
            f"gui_object_position {x0} 696 {x1} 946", f'gui_object_name "{objname}"', "gui_object_frigid 0", "gui_object_end"]
out = []
for o in objs:
    i, l = get(o, "gui_object_position"); _, x0, y0, x1, y1 = l.split(); x0, x1 = int(x0), int(x1)
    if pic(o) == "mainpanel_bg_1680.png":
        out += [mk("mainpanel_bg_3360_b.png", 1680, 3360, "panel_b"), mk("mainpanel_bg_3360_a.png", 0, 1682, "panel_a")]; continue
    if pic(o) == "border.png" and x0 == 0 and x1 == 1680:
        o[i] = f"gui_object_position 0 {y0} {NEW_W} {y1}"; out.append(o); continue
    g0, g1 = group(x0), group(max(x0, x1 - 1))
    if g0 != g1: print("CROSS-GROUP:", name(o), x0, x1, g0, g1)
    o[i] = f"gui_object_position {x0+dx[g0]} {y0} {x1+dx[g0]} {y1}"; out.append(o)
lines = head + [l for o in out for l in o] + [tail]
open(dst, "w", newline="").write("\r\n".join(lines))
print("objects:", len(objs), "->", len(out))
