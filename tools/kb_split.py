#!/usr/bin/env python3
"""
kb_split.py - разрезать общий манифест (kb_manifest.py на папку, где лежат ВСЕ игры) на манифесты по играм.

  python kb_manifest.py "D:\\Games\\KB" --name all --out kb_manifests
  python kb_split.py kb_manifests\\all.manifest.json
  python kb_compare.py kb_manifests\\legend.manifest.json kb_manifests\\wotn.manifest.json --out report_wotn.md

Игра определяется по имени верхней папки (legend, red sands, crossworlds, dark side, north, princess).
Остальные папки (моды, дампы) пропускаются.
"""
import json, os, sys, collections

KEYS = [("red sands", "red_sands"), ("red_sands", "red_sands"), ("crossworlds", "crossworlds"),
        ("dark side", "dark_side"), ("darkside", "dark_side"), ("north", "wotn"),
        ("armored", "armored_princess"), ("princess", "armored_princess"), ("legend", "legend")]

def game_of(folder):
    f = folder.lower()
    for k, v in KEYS:
        if k in f:
            return v
    return None

def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else os.path.dirname(os.path.abspath(src))
    m = json.load(open(src, encoding="utf-8"))
    parts = collections.defaultdict(list)
    for r in m["files"]:
        top, _, rest = r["path"].partition("/")
        g = game_of(top)
        if g and rest:
            r = dict(r); r["path"] = rest; parts[g].append(r)
    for g, v in parts.items():
        p = os.path.join(out, f"{g}.manifest.json")
        json.dump({"game": g, "version": 1, "hash_mode": m.get("hash_mode", ""), "file_count": len(v),
                   "total_bytes": sum(x["size"] for x in v), "errors": [], "files": v},
                  open(p, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
        print(f"{g}: {len(v)} файлов -> {p}")

if __name__ == "__main__":
    main()
