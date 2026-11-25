"""Shift one named object in a .ui file by (dx, dy) pixels. Keeps CRLF and everything else intact.

Usage:  python ui_nudge.py <file.ui> <object_name> <dx> <dy> [--dry]
Example (loading screen ring 3 px up):  python ui_nudge.py loading_3360x945.ui progressbar 0 -3
If several objects share the name, all of them are moved (the count is printed).
"""
import sys


def nudge(text, name, dx, dy):
    """Return (new_text, count). Works on raw text so line endings are preserved."""
    lines = text.split("\n")
    out, count = [], 0
    start = 0
    for i, ln in enumerate(lines):
        if ln.strip().startswith("gui_object_begin"):
            start = i
        if ln.strip() == "gui_object_end":
            block = lines[start:i + 1]
            names = [b.split('"')[1] for b in block if b.strip().startswith("gui_object_name")]
            if name in names:
                for j, b in enumerate(block):
                    if b.strip().startswith("gui_object_position"):
                        cr = "\r" if b.endswith("\r") else ""
                        _, x0, y0, x1, y1 = b.split()
                        block[j] = "gui_object_position %d %d %d %d%s" % (
                            int(x0) + dx, int(y0) + dy, int(x1) + dx, int(y1) + dy, cr)
                lines[start:i + 1] = block
                count += 1
    return "\n".join(lines), count


if __name__ == "__main__":
    if len(sys.argv) < 5:
        sys.exit(__doc__)
    path, name, dx, dy = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    raw = open(path, newline="", encoding="latin-1").read()
    new, n = nudge(raw, name, dx, dy)
    if n == 0:
        sys.exit("object %r not found" % name)
    print("moved %d object(s) named %r by (%d, %d)" % (n, name, dx, dy))
    if "--dry" not in sys.argv:
        open(path, "w", newline="", encoding="latin-1").write(new)
