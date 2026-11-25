#!/usr/bin/env python3
"""
kb_compare.py - сравнение манифестов разных игр серии (см. kb_manifest.py).

  python kb_compare.py legend.manifest.json wotn.manifest.json --out report_wotn.md
  python kb_compare.py legend.manifest.json wotn.manifest.json darkside.manifest.json --out report.md

Первый манифест - база (оригинал, Legend). Остальные сравниваются с ней.
Файлы сопоставляются ПО ИМЕНИ (без папки и без имени архива): так видно, что есть
в новой игре и чего нет в Legend, даже если файл лежит в другом .kfs.
Отчёт - Markdown, содержимого игр в нём нет (только имена, размеры, статистика).
"""
import argparse, json, os, sys
from collections import Counter, defaultdict

CODE_EXT = {".lua", ".lu", ".txt", ".ui", ".ini", ".cfg", ".csv", ".atom", ".qst", ".act", ".hero", ".chat", ".strg"}

def load(p):
    with open(p, encoding="utf-8") as f:
        m = json.load(f)
    for r in m["files"]:
        r["name"] = os.path.basename(r["path"]).lower()
        r["container"] = r["path"].split("!/")[0] if "!/" in r["path"] else (os.path.dirname(r["path"]) or ".")
        r["sig"] = r.get("crc") or ""
    return m

def mb(n): return f"{n/1048576:.1f} МБ"

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("manifests", nargs="+")
    ap.add_argument("--out", default="")
    ap.add_argument("--top", type=int, default=25)
    a = ap.parse_args()
    if len(a.manifests) < 2:
        sys.exit("Нужно минимум два манифеста")

    games = [load(p) for p in a.manifests]
    base, others = games[0], games[1:]
    L = []; w = L.append

    w("# Сравнение игр серии\n")
    w("| Игра | Файлов (с содержимым .kfs) | Размер |\n|---|---|---|")
    for g in games:
        w(f"| {g['game']} | {g['file_count']} | {mb(g['total_bytes'])} |")
    w("")

    all_ext = sorted({r["ext"] for g in games for r in g["files"]})
    cnts = [Counter(r["ext"] for r in g["files"]) for g in games]
    w("## Расширения по играм (число файлов)\n")
    w("| Ext | " + " | ".join(g["game"] for g in games) + " |")
    w("|---|" + "---|" * len(games))
    for e in all_ext:
        w(f"| `{e or '(нет)'}` | " + " | ".join(str(c.get(e, 0)) for c in cnts) + " |")
    w("")

    w("## Сигнатуры форматов (первые 4 байта) у обычных файлов\n")
    w("Одинаковые сигнатуры у одного расширения в разных играх - формат, скорее всего, тот же. "
      "У файлов из архивов сигнатур в манифесте нет.\n")
    w("| Ext | " + " | ".join(g["game"] for g in games) + " |")
    w("|---|" + "---|" * len(games))
    for e in all_ext:
        cells, any_data = [], False
        for g in games:
            sigs = Counter(r["head"][:8] for r in g["files"] if r["ext"] == e and r["head"])
            any_data |= bool(sigs)
            cells.append(", ".join(f"`{s}`x{n}" for s, n in sigs.most_common(3)) or "-")
        if any_data:
            w(f"| `{e or '(нет)'}` | " + " | ".join(cells) + " |")
    w("")

    base_by_name = defaultdict(list)
    for r in base["files"]:
        base_by_name[r["name"]].append(r)

    for g in others:
        new, same, diff = [], 0, []
        for r in g["files"]:
            cand = base_by_name.get(r["name"])
            if not cand:
                new.append(r); continue
            if r["sig"] and any(c["sig"] == r["sig"] for c in cand):
                same += 1
            elif r["sig"] and any(c["sig"] for c in cand):
                diff.append((r, cand[0]))
            # без CRC у одной из сторон - не считаем ни тем, ни другим

        w(f"## {base['game']} -> {g['game']}\n")
        w("Сопоставление по имени файла (папка и архив не учитываются).\n")
        w(f"- Есть в обеих, содержимое одинаковое: **{same}**")
        w(f"- Есть в обеих, содержимое отличается: **{len(diff)}**")
        w(f"- Нет в {base['game']} вообще (кандидаты на перенос): **{len(new)}** ({mb(sum(r['size'] for r in new))})\n")

        agg = defaultdict(lambda: [0, 0])
        for r in new:
            k = (r["container"], r["ext"]); agg[k][0] += 1; agg[k][1] += r["size"]
        w(f"### Новое в {g['game']}: где лежит и какого типа (топ {a.top} по размеру)\n")
        w("| Папка или архив | Ext | Файлов | Размер |\n|---|---|---|---|")
        for (d, e), (c, s) in sorted(agg.items(), key=lambda x: -x[1][1])[:a.top]:
            w(f"| `{d}` | `{e}` | {c} | {mb(s)} |")
        w("")

        code_new = sorted([r for r in new if r["ext"] in CODE_EXT], key=lambda r: -r["size"])[:a.top]
        if code_new:
            w(f"### Новые скрипты и данные в {g['game']} (топ {a.top} по размеру)\n")
            for r in code_new:
                w(f"- `{r['path']}` ({r['size']} Б)")
            w("")

        code_diff = sorted([(r, c) for r, c in diff if r["ext"] in CODE_EXT], key=lambda x: -x[0]["size"])
        if code_diff:
            w(f"### Те же имена, но другое содержимое: скрипты и данные (топ {a.top} по размеру)\n")
            w(f"| Файл в {g['game']} | Байт | Байт в {base['game']} |\n|---|---|---|")
            for r, c in code_diff[:a.top]:
                w(f"| `{r['path']}` | {r['size']} | {c['size']} |")
            w("")

    txt = "\n".join(L)
    if a.out:
        with open(a.out, "w", encoding="utf-8") as f:
            f.write(txt)
        print("Отчёт:", a.out)
    else:
        print(txt)

if __name__ == "__main__":
    main()
