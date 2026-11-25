#!/usr/bin/env python3
"""
kb_texture_inventory.py - опись текстур игры (DDS/PNG/TGA) из папок и .kfs, без распаковки.
Читает только заголовки: размер, формат (DXT1/DXT5/...), число mip-уровней, наличие альфы.
Нужна, чтобы решить, какие текстуры стоит апскейлить и сколько это съест памяти.

  python tools/kb_texture_inventory.py "D:\\Games\\KB\\KB The Legend EE" --out tex_inventory

Результат: <out>/inventory.csv и <out>/SUMMARY.md. Игра не меняется. Только стандартная библиотека Python.
Классы (по имени): diffuse (_diff), spec (_spec), data (_mask/_bump/_height), fx (частицы/эффекты),
special (вода, кубы, тестовые), other (остальное, обычно окружение), ui (png интерфейса), sky.
"""
import argparse, csv, os, re, struct, sys, zipfile, collections

def classify(path):
    p = path.lower(); n = os.path.basename(p)
    if "interface_textures" in p: return "ui"
    if "sky.kfs" in p: return "sky"
    if re.search(r"^(fx|fxm)|_fx\b|particle", n): return "fx"
    if n.endswith("_spec.dds"): return "spec"
    if re.search(r"(_mask|_bump|_height|_h)\.dds$", n): return "data"
    if re.search(r"^(water|dxt)|cube|checkboard", n): return "special"
    if n.endswith("_diff.dds"): return "diffuse"
    return "other"

def parse_dds(b):
    """-> dict(w,h,mips,fmt,alpha) или None"""
    if len(b) < 128 or b[:4] != b"DDS ":
        return None
    h, w, mips = struct.unpack_from("<III", b, 12)[0], struct.unpack_from("<I", b, 16)[0], struct.unpack_from("<I", b, 28)[0]
    pf_flags, fourcc = struct.unpack_from("<I4s", b, 80)
    bits, rmask, gmask, bmask, amask = struct.unpack_from("<IIIII", b, 88)
    fc = fourcc.decode("latin-1").strip("\x00")
    if pf_flags & 0x4:                       # FOURCC
        if fc == "DX10" and len(b) >= 132:
            fmt = "DXGI%d" % struct.unpack_from("<I", b, 128)[0]
        else:
            fmt = fc
        alpha = fmt in ("DXT3", "DXT5", "DXT2", "DXT4")
    else:
        fmt = "RGB%d" % bits if not (pf_flags & 0x1) else "RGBA%d" % bits
        alpha = bool(pf_flags & 0x1)
    return {"w": w, "h": h, "mips": max(mips, 1), "fmt": fmt, "alpha": alpha}

def parse_png(b):
    if len(b) < 26 or b[:8] != b"\x89PNG\r\n\x1a\n":
        return None
    w, h = struct.unpack(">II", b[16:24]); ctype = b[25]
    return {"w": w, "h": h, "mips": 1, "fmt": "PNG", "alpha": ctype in (4, 6)}

def parse_tga(b):
    if len(b) < 18:
        return None
    w, h = struct.unpack_from("<HH", b, 12); bpp = b[16]
    return {"w": w, "h": h, "mips": 1, "fmt": "TGA%d" % bpp, "alpha": bpp == 32}

PARSERS = {".dds": parse_dds, ".png": parse_png, ".tga": parse_tga}

def entries(root):
    for dp, dn, fn in os.walk(root):
        for name in sorted(fn):
            p = os.path.join(dp, name); rel = os.path.relpath(p, root).replace("\\", "/")
            e = os.path.splitext(name)[1].lower()
            if e in PARSERS:
                with open(p, "rb") as f:
                    yield rel, os.path.getsize(p), f.read(200)
            elif e == ".kfs":
                try:
                    z = zipfile.ZipFile(p)
                except (zipfile.BadZipFile, OSError):
                    continue
                for zi in z.infolist():
                    ie = os.path.splitext(zi.filename)[1].lower()
                    if not zi.is_dir() and ie in PARSERS:
                        with z.open(zi) as f:
                            yield f"{rel}!/{zi.filename}", zi.file_size, f.read(200)

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("root"); ap.add_argument("--out", default="tex_inventory")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True); rows = []
    for path, size, head in entries(os.path.abspath(a.root)):
        info = PARSERS[os.path.splitext(path)[1].lower()](head)
        if not info:
            continue
        rows.append({"path": path, "class": classify(path), "w": info["w"], "h": info["h"], "mips": info["mips"],
                     "fmt": info["fmt"], "alpha": int(info["alpha"]), "bytes": size})
    with open(os.path.join(a.out, "inventory.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()) if rows else ["path"]); w.writeheader(); w.writerows(rows)

    L = [f"# Опись текстур ({len(rows)} файлов)\n", "## По классам\n", "| Класс | Файлов | МБ | Макс. сторона (медиана) |", "|---|---|---|---|"]
    by = collections.defaultdict(list)
    for r in rows: by[r["class"]].append(r)
    for k, v in sorted(by.items(), key=lambda x: -sum(r["bytes"] for r in x[1])):
        sides = sorted(max(r["w"], r["h"]) for r in v)
        L.append(f"| {k} | {len(v)} | {sum(r['bytes'] for r in v)/1048576:.0f} | {sides[len(sides)//2]} |")
    L += ["", "## Форматы (DDS)\n", "| Формат | Файлов |", "|---|---|"]
    for k, n in collections.Counter(r["fmt"] for r in rows if r["path"].lower().endswith(".dds")).most_common():
        L.append(f"| {k} | {n} |")
    L += ["", "## Размеры сторон (diffuse + other)\n", "| Сторона | Файлов | МБ |", "|---|---|---|"]
    sz = collections.defaultdict(lambda: [0, 0])
    for r in rows:
        if r["class"] in ("diffuse", "other"):
            m = max(r["w"], r["h"]); sz[m][0] += 1; sz[m][1] += r["bytes"]
    for m in sorted(sz): L.append(f"| {m} | {sz[m][0]} | {sz[m][1]/1048576:.0f} |")
    cand = [r for r in rows if r["class"] in ("diffuse", "other") and max(r["w"], r["h"]) <= 1024]
    big = sum(r["bytes"] for r in cand) / 1048576
    L += ["", "## Оценка памяти при апскейле\n",
          f"Кандидаты (diffuse/other, сторона <= 1024): **{len(cand)}** файлов, **{big:.0f} МБ**.",
          f"Апскейл x2 даёт ~x4 по объёму: **{4*big:.0f} МБ**; x1.5 - около **{2.25*big:.0f} МБ**. "
          "Игра 32-битная (kb.exe), поэтому апскейл всего подряд опасен: начинать с подмножества."]
    open(os.path.join(a.out, "SUMMARY.md"), "w", encoding="utf-8").write("\n".join(L))
    print(f"Готово: {len(rows)} текстур -> {a.out}\\inventory.csv и SUMMARY.md")

if __name__ == "__main__":
    main()
