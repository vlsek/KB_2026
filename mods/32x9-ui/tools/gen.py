import sys, os, re
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ui_nudge import nudge
src, dst = sys.argv[1], sys.argv[2]
OLD_W, H, NEW_W = 1680, 945, 3360
DX = (NEW_W - OLD_W) // 2
os.makedirs(dst, exist_ok=True)

STRETCH = {"black_pixel.png", "border.png"}   # fills / vignette: stretch to full width
# Per-screen fixes on top of the plain +DX shift: {screen: [(object_name, dx, dy), ...]}
NUDGE = {"loading": [("progressbar", 0, -3)]}  # ring sat ~3 px too low in its groove (owner, 2026-11-25)
FILL = {"start", "loading", "credits", "intro", "new_game"}  # add black backdrop

def conv(name):
    raw = open(f"{src}/{name}_1680x945.ui", newline="").read()
    lines = raw.replace("\r\n", "\n").split("\n")
    out, pic, n_ext = [], "", 0
    for ln in lines:
        if ln.startswith("gui_begin"):
            ln = f"gui_begin {NEW_W} {H}"
        elif ln.startswith("gui_object_begin"):
            pic = ""
        elif ln.startswith("gui_object_picture "):
            pic = ln.split('"')[1]
        elif ln.startswith("gui_object_position"):
            _, x0, y0, x1, y1 = ln.split()
            x0, x1 = int(x0), int(x1)
            if x0 == 0 and x1 == OLD_W and pic in STRETCH:
                x1 = NEW_W; n_ext += 1
            else:
                x0 += DX; x1 += DX
            ln = f"gui_object_position {x0} {y0} {x1} {y1}"
        elif ln.startswith("gui_end") and name in FILL:
            out += ["gui_object_begin picture",
                    'gui_object_picture "black_pixel.png"',
                    "gui_object_picture_angle 0.000000 0",
                    f"gui_object_position 0 -100 {NEW_W} 1050",
                    'gui_object_name "bg_black_wide"',
                    "gui_object_frigid 0",
                    "gui_object_end"]
        out.append(ln)
    text = "\r\n".join(out)
    for oname, ndx, ndy in NUDGE.get(name, []):
        text, cnt = nudge(text, oname, ndx, ndy)
        print(name, "nudged", oname, (ndx, ndy), "x", cnt)
    open(f"{dst}/{name}_3360x945.ui", "w", newline="").write(text)
    print(name, "stretched:", n_ext)

names = ["arena", "credits", "intro", "loading", "map", "new_game", "start", "town"]
for n in names: conv(n)

# resolutions.txt
r = open(f"{src}/resolutions.txt", newline="").read()
if not r.endswith("\n"): r += "\r\n"
r += "32.9=3360x945"
open(f"{dst}/resolutions.txt", "w", newline="").write(r)

# forms.txt: add a 3360x945 line after every 1680x945 line
f = open(f"{src}/forms.txt", newline="").read()
def add(m):
    indent, fn = m.group(1), m.group(2)
    return f"{m.group(0)}{m.group(3)}{indent}3360x945={fn.replace('1680x945','3360x945')}"
f2, cnt = re.subn(r"(?m)^([ \t]*)1680x945=(\S+)(\r?\n)", lambda m: m.group(0) + f"{m.group(1)}3360x945={m.group(2).replace('1680x945','3360x945')}{m.group(3)}", f)
open(f"{dst}/forms.txt", "w", newline="").write(f2)
print("forms lines added:", cnt)
