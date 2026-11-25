#!/usr/bin/env python3
"""
kb_extract.py - достать несколько конкретных файлов из папки игры и из её .kfs (zip) в одну папку.
Нужен, чтобы прислать небольшие файлы-образцы, не распаковывая гигабайты.

  python kb_extract.py "D:\\Games\\KB\\Kings Bounty - Crossworlds" --out ref\\crossworlds --name addon_rewards.lua medals.txt records.txt
  python kb_extract.py "D:\\Games\\KB\\KB The Legend EE" --out ref\\legend --name achievements.txt records.txt

Имена - точные имена файлов (без пути), регистр не важен. Если одно имя встречается в нескольких
архивах, сохраняются все: имя результата = <путь в игре с заменой / и ! на __>. Игра не меняется.
Результат не коммитим в репо (это файлы игры): архивируйте папку --out и присылайте в чат.
"""
import argparse, os, sys, zipfile

def safe(s): return s.replace("!/", "__").replace("/", "__").replace("\\", "__")

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("root"); ap.add_argument("--out", required=True)
    ap.add_argument("--name", nargs="+", required=True)
    ap.add_argument("--max-mb", type=float, default=2.0, help="пропускать файлы больше (по умолчанию 2 МБ)")
    a = ap.parse_args()
    want = {n.lower() for n in a.name}; lim = int(a.max_mb * 1048576)
    os.makedirs(a.out, exist_ok=True); root = os.path.abspath(a.root); n = 0
    for dp, dn, fn in os.walk(root):
        for name in sorted(fn):
            p = os.path.join(dp, name); rel = os.path.relpath(p, root).replace("\\", "/")
            if name.lower() in want and os.path.getsize(p) <= lim:
                open(os.path.join(a.out, safe(rel)), "wb").write(open(p, "rb").read()); n += 1; print("  ", rel)
            if name.lower().endswith(".kfs"):
                try: z = zipfile.ZipFile(p)
                except (zipfile.BadZipFile, OSError): continue
                for zi in z.infolist():
                    if not zi.is_dir() and os.path.basename(zi.filename).lower() in want and zi.file_size <= lim:
                        open(os.path.join(a.out, safe(f"{rel}!/{zi.filename}")), "wb").write(z.read(zi)); n += 1
                        print("  ", f"{rel}!/{zi.filename}")
    print(f"Готово: {n} файлов -> {a.out}")

if __name__ == "__main__":
    main()
