#!/usr/bin/env python3
"""Rebuilds docs/GIT_HISTORY.md from git log: who changed what, grouped by day and author.
Run from the repo root:  python tools/gen_git_history.py
This file is generated - do not edit by hand. The hand-written changelog is CHANGELOG.md (mandatory for every agent)."""
import subprocess, collections, re, sys
raw = subprocess.check_output(["git", "log", "--no-merges", "--date=format:%Y-%m-%d", "--format=%ad|%an|%h|%s"], text=True, encoding="utf-8")
def who(a):
    a = a.strip().lower().replace("-", " ")
    m = re.search(r"agent\s*(\d)", a)
    if m: return "Агент " + m.group(1)
    if a in ("claude",): return "Claude (координатор)"
    if a == "vlsek": return "Владелец (vlsek)"
    return a
days = collections.OrderedDict()
for line in raw.splitlines():
    d, a, h, s = line.split("|", 3)
    days.setdefault(d, collections.OrderedDict()).setdefault(who(a), []).append((h, s))
out = ["# История изменений из git (генерируется)", "",
       "Автоматически собрано `tools/gen_git_history.py` из `git log`. Руками не править. Человеческий ченджлог - `CHANGELOG.md` (обязателен для каждого агента).", ""]
for d, authors in days.items():
    out.append("## " + d)
    for a, items in authors.items():
        out.append("**" + a + "**")
        for h, s in items: out.append("- `" + h + "` " + s)
        out.append("")
open("docs/GIT_HISTORY.md", "w", encoding="utf-8").write("\n".join(out))
print("docs/GIT_HISTORY.md:", sum(len(v) for a in days.values() for v in a.values()), "commits")
