#!/usr/bin/env python3
"""
kb_manifest.py — манифест папки игры для проекта KB_2026.

Только читает. Игровые файлы не копирует и не изменяет: в манифест попадают
относительные пути, размеры, даты, первые байты файла (сигнатура формата) и хэш.

Использование:
  python kb_manifest.py "C:\\Games\\KB The Legend" --name legend
  python kb_manifest.py "D:\\Games\\KB Armored Princess" --name armored_princess

Архивы .kfs (это zip) раскрываются по оглавлению, без распаковки: их содержимое попадает в манифест
как "data/models.kfs!/внутренний/путь" с размером и CRC32. Отключить: --no-archives.
Для обычных файлов до 8 МБ тоже считается CRC32 (поле "crc"), чтобы сравнивать их с файлами из архивов.

Результат: <out>/<name>.manifest.json и <out>/<name>.summary.csv
Для сравнения игр: kb_compare.py
"""
import argparse, csv, hashlib, json, os, sys, time, zipfile, zlib
from collections import defaultdict

HEAD = 16                      # сколько первых байт сохраняем как сигнатуру
FAST_BYTES = 1024 * 1024       # для режима --hash fast: хэш первого мегабайта + размер

KNOWN = [                      # (префикс байт, метка) — грубое определение типа
    (b"PK\x03\x04", "zip"), (b"OggS", "ogg"), (b"\x89PNG", "png"),
    (b"DDS ", "dds"), (b"RIFF", "riff/wav"), (b"BM", "bmp"),
    (b"\xff\xd8\xff", "jpeg"), (b"ID3", "mp3"), (b"MZ", "exe/dll"),
    (b"\x1bLua", "lua-bytecode"), (b"\xef\xbb\xbf", "utf8-bom-text"),
    (b"GIF8", "gif"), (b"Rar!", "rar"), (b"7z\xbc\xaf", "7z"),
]

def sniff(head: bytes) -> str:
    for pref, label in KNOWN:
        if head.startswith(pref):
            return label
    if head and all(32 <= b < 127 or b in (9, 10, 13) for b in head):
        return "text?"
    return "unknown"

def file_hash(path, size, mode):
    if mode == "none":
        return ""
    h = hashlib.sha1()
    with open(path, "rb") as f:
        if mode == "fast":
            h.update(f.read(FAST_BYTES)); h.update(str(size).encode())
        else:
            for chunk in iter(lambda: f.read(1 << 20), b""):
                h.update(chunk)
    return h.hexdigest()

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("root", help="папка игры")
    ap.add_argument("--name", required=True, help="короткое имя игры: legend, armored_princess, ...")
    ap.add_argument("--out", default="kb_manifests", help="куда писать результат")
    ap.add_argument("--hash", choices=["none", "fast", "full"], default="fast",
                    help="fast (по умолчанию): первый МБ + размер; full: весь файл; none: без хэша")
    ap.add_argument("--no-archives", action="store_true", help="не заглядывать внутрь .kfs/.zip")
    a = ap.parse_args()

    root = os.path.abspath(a.root)
    if not os.path.isdir(root):
        sys.exit(f"Не папка: {root}")
    os.makedirs(a.out, exist_ok=True)

    rows, errors, t0 = [], [], time.time()
    for dp, dn, fn in os.walk(root):
        dn.sort()
        for name in sorted(fn):
            p = os.path.join(dp, name)
            rel = os.path.relpath(p, root).replace("\\", "/")
            try:
                st = os.stat(p)
                with open(p, "rb") as f:
                    head = f.read(HEAD)
                crc = ""
                if a.hash != "none" and st.st_size <= 8 * 1048576:
                    with open(p, "rb") as f:
                        crc = "%08x" % (zlib.crc32(f.read()) & 0xFFFFFFFF)
                rows.append({
                    "crc": crc,
                    "path": rel,
                    "ext": os.path.splitext(name)[1].lower(),
                    "size": st.st_size,
                    "date": time.strftime("%Y-%m-%d", time.gmtime(st.st_mtime)),
                    "head": head.hex(),
                    "kind": sniff(head),
                    "hash": file_hash(p, st.st_size, a.hash),
                })
                if not a.no_archives and (os.path.splitext(name)[1].lower() == ".kfs" or head.startswith(b"PK\x03\x04")):
                    try:
                        with zipfile.ZipFile(p) as z:
                            for zi in z.infolist():
                                if zi.is_dir():
                                    continue
                                inner = zi.filename.replace("\\", "/")
                                rows.append({
                                    "path": f"{rel}!/{inner}",
                                    "ext": os.path.splitext(inner)[1].lower(),
                                    "size": zi.file_size,
                                    "date": "%04d-%02d-%02d" % zi.date_time[:3],
                                    "head": "", "kind": "in-archive",
                                    "hash": "", "crc": "%08x" % zi.CRC,
                                })
                    except (zipfile.BadZipFile, NotImplementedError, OSError) as e:
                        errors.append(f"{rel}: не открылся как zip: {e}")
            except OSError as e:
                errors.append(f"{rel}: {e}")
        if len(rows) and len(rows) % 2000 < len(fn):
            print(f"  ...{len(rows)} файлов", file=sys.stderr)

    manifest = {
        "game": a.name, "version": 1, "hash_mode": a.hash,
        "file_count": len(rows), "total_bytes": sum(r["size"] for r in rows),
        "errors": errors, "files": rows,
    }
    mp = os.path.join(a.out, f"{a.name}.manifest.json")
    with open(mp, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, separators=(",", ":"))

    agg = defaultdict(lambda: [0, 0, set()])
    for r in rows:
        d = os.path.dirname(r["path"]) or "."
        k = (d, r["ext"])
        agg[k][0] += 1; agg[k][1] += r["size"]; agg[k][2].add(r["kind"])
    sp = os.path.join(a.out, f"{a.name}.summary.csv")
    with open(sp, "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["dir", "ext", "files", "size_mb", "kinds"])
        for (d, e), (c, s, kinds) in sorted(agg.items()):
            w.writerow([d, e, c, round(s / 1048576, 2), "|".join(sorted(kinds))])

    print(f"Готово за {time.time()-t0:.1f}с: {len(rows)} файлов, "
          f"{manifest['total_bytes']/1048576:.1f} МБ, ошибок: {len(errors)}")
    print(f"  {mp}\n  {sp}")

if __name__ == "__main__":
    main()
