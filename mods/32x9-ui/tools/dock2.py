"""Dock a 1680x945 .ui to the edges of a 3360x945 screen: objects with x0 < SPLIT stay left, others move right by 1680.
usage: dock2.py src.ui dst.ui SPLIT"""
import sys
src, dst, split = sys.argv[1], sys.argv[2], int(sys.argv[3])
NEW_W = 3360
lines = open(src, newline="").read().replace("\r\n", "\n").split("\n")
out, cross, cur = [], [], ""
for ln in lines:
    if ln.startswith("gui_begin"): ln = f"gui_begin {NEW_W} 945"
    elif ln.startswith("gui_object_name"): cur = ln.split('"')[1]
    elif ln.startswith("gui_object_position"):
        _, x0, y0, x1, y1 = ln.split(); x0, x1 = int(x0), int(x1)
        d = 0 if x0 < split else NEW_W - 1680
        if (x0 < split) != (max(x0, x1 - 1) < split): cross.append((x0, x1))
        ln = f"gui_object_position {x0+d} {y0} {x1+d} {y1}"
    out.append(ln)
open(dst, "w", newline="").write("\r\n".join(out))
print("crossing objects:", cross)
