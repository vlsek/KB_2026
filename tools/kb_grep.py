#!/usr/bin/env python3
"""
kb_grep.py — поиск по текстовым файлам игры, включая содержимое .kfs (zip) без распаковки на диск.

Примеры:
  python kb_grep.py "C:\\Games\\KB Dark Side" achievement steam -i
  python kb_grep.py "C:\\Games\\KB Dark Side" "SteamAPI|achiev" --regex --out dark_side_grep.txt
  python kb_grep.py "<папка игры>" achievement --list-only        # только имена файлов

Ищет в текстовых файлах (UTF-8, cp1251, UTF-16 с BOM); бинарные пропускает. Ничего не меняет.
Вывод: файл, номер строки, обрезанная строка (до 160 символов). Не коммитьте вывод целиком в репо
(там строки из игры); для документации достаточно имён файлов и 1–2 коротких примеров.
"""
import argparse, os, re, sys, zipfile

TEXT_EXT = {".lua", ".lu", ".txt", ".ini", ".cfg", ".csv", ".atom", ".ui", ".json", ".xml",
            ".act", ".qst", ".hero", ".chat", ".loc", ".lng", ".strg", ".script", ".info"}

def members(root, exts, scan_archives):
    for dp, dn, fn in os.walk(root):
        dn.sort()
        for name in sorted(fn):
            p = os.path.join(dp, name)
            rel = os.path.relpath(p, root).replace("\\", "/")
            e = os.path.splitext(name)[1].lower()
            if e in exts:
                yield rel, lambda p=p: open(p, "rb").read()
            if scan_archives and e == ".kfs":
                try:
                    z = zipfile.ZipFile(p)
                except (zipfile.BadZipFile, OSError):
                    continue
                for zi in z.infolist():
                    if zi.is_dir():
                        continue
                    ie = os.path.splitext(zi.filename)[1].lower()
                    if ie in exts:
                        yield f"{rel}!/{zi.filename}", lambda z=z, zi=zi: z.read(zi)

def decode(b):
    if b[:2] in (b"\xff\xfe", b"\xfe\xff"):        # UTF-16 с BOM (так лежат тексты и конфиги в части игр)
        return b.decode("utf-16", errors="replace")
    if b"\x00" in b[:4096]:
        return None
    for enc in ("utf-8-sig", "cp1251"):
        try:
            return b.decode(enc)
        except UnicodeDecodeError:
            pass
    return b.decode("latin-1")

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("root")
    ap.add_argument("patterns", nargs="+", help="подстроки (или регулярки с --regex)")
    ap.add_argument("-i", "--ignore-case", action="store_true")
    ap.add_argument("--regex", action="store_true")
    ap.add_argument("--ext", default="", help="свой список расширений через запятую, например .lua,.txt")
    ap.add_argument("--no-archives", action="store_true")
    ap.add_argument("--list-only", action="store_true")
    ap.add_argument("--max-per-file", type=int, default=5)
    ap.add_argument("--out", default="")
    a = ap.parse_args()

    exts = {e if e.startswith(".") else "." + e for e in a.ext.lower().split(",") if e} or TEXT_EXT
    flags = re.I if a.ignore_case else 0
    pat = re.compile("|".join(a.patterns if a.regex else map(re.escape, a.patterns)), flags)

    out, files_hit, total_hits, scanned = [], 0, 0, 0
    by_area = {}
    for name, read in members(os.path.abspath(a.root), exts, not a.no_archives):
        try:
            text = decode(read())
        except Exception as e:
            out.append(f"! {name}: {e}"); continue
        if text is None:
            continue
        scanned += 1
        hits = [(i, ln) for i, ln in enumerate(text.splitlines(), 1) if pat.search(ln)]
        if not hits:
            continue
        files_hit += 1; total_hits += len(hits)
        area = name.split("!/")[0] if "!/" in name else os.path.dirname(name) or "."
        by_area[area] = by_area.get(area, 0) + len(hits)
        out.append(f"{name}  ({len(hits)})")
        if not a.list_only:
            for i, ln in hits[:a.max_per_file]:
                out.append(f"    {i}: {ln.strip()[:160]}")
    out.append("")
    out.append(f"Просмотрено текстовых файлов: {scanned}; файлов с совпадениями: {files_hit}; всего строк: {total_hits}")
    for k, v in sorted(by_area.items(), key=lambda x: -x[1])[:15]:
        out.append(f"  {v:6d}  {k}")
    txt = "\n".join(out)
    if a.out:
        open(a.out, "w", encoding="utf-8").write(txt)
        print("Готово:", a.out, "|", out[-1 - min(len(by_area), 15)])
    else:
        print(txt)

if __name__ == "__main__":
    main()
