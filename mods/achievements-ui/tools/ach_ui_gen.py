"""Генератор пробного интерфейса достижений для Legend EE под 32:9 (агент 1).
Вход: .ui из Воина Севера/Dark Side (achievements.ui, new_achievement.ui, hero.ui) и .ui Legend (hero.ui, forms.txt мода 32x9).
Выход: *_3360x945.ui по центру, hero.ui Legend с кнопкой ahievements_button, forms.txt с блоками форм.
Файлы игр в репозиторий не кладём — скрипт запускается у владельца.
usage: ach_ui_gen.py WN_UI_DIR LEGEND_UI_DIR MOD_DIR OUT_DIR [--btn X Y]"""
import re, sys, os
wn, leg, mod, out = sys.argv[1:5]
BX, BY = 1190, 30                       # место кнопки в окне героя (1280x960) — подбирается по скриншоту
if "--btn" in sys.argv:
    i = sys.argv.index("--btn"); BX, BY = int(sys.argv[i+1]), int(sys.argv[i+2])
os.makedirs(out, exist_ok=True)
rd = lambda p: open(p, encoding="utf-8", errors="replace", newline="").read().replace("\r\n", "\n")
wr = lambda p, t: open(p, "w", encoding="utf-8", newline="").write(t.replace("\n", "\r\n"))
NEW_W, H = 3360, 945

def split(t):
    objs = re.findall(r"gui_object_begin \w+\n.*?gui_object_end\n", t, flags=re.S)
    return t[:t.index("gui_object_begin")], objs
def name(o): return re.search(r'gui_object_name "([^"]*)"', o).group(1)
def shift(o, dx, dy):
    return re.sub(r"gui_object_position (-?\d+) (-?\d+) (-?\d+) (-?\d+)",
                  lambda m: f"gui_object_position {int(m[1])+dx} {int(m[2])+dy} {int(m[3])+dx} {int(m[4])+dy}", o)
def bbox(objs, nm):
    o = next(o for o in objs if name(o) == nm)
    return tuple(map(int, re.search(r"gui_object_position (-?\d+) (-?\d+) (-?\d+) (-?\d+)", o).groups()))

def center_window(src, dst, bgname, dy=None, drop=()):
    head, objs = split(rd(src))
    x0, y0, x1, y1 = bbox(objs, bgname)
    dx = (NEW_W - (x1 - x0)) // 2 - x0
    dy = (H - (y1 - y0)) // 2 - y0 if dy is None else dy
    keep = [shift(o, dx, dy) for o in objs if not name(o) in drop]
    wr(dst, f"gui_begin {NEW_W} {H}\n" + "".join(keep))
    print(os.path.basename(dst), "dx", dx, "dy", dy, "objects", len(keep))

center_window(f"{wn}/achievements.ui", f"{out}/achievements_3360x945.ui", "bg")
# всплывашка: сверху по центру; кнопки публикации в соцсети убираем
center_window(f"{wn}/new_achievement.ui", f"{out}/new_achievement_3360x945.ui", "new_achievement_background", dy=60,
              drop=("b_publish_fb", "b_publish_tw", "b_publish_vk"))

# кнопка «достижения» в окне героя Legend (имя ahievements_button — с опечаткой, как в WotN, по нему движок и узнаёт кнопку)
_, wobjs = split(rd(f"{wn}/hero.ui"))
btn = next(o for o in wobjs if name(o) == "ahievements_button")
btn = re.sub(r"gui_object_position .*", f"gui_object_position {BX} {BY} {BX+64} {BY+65}", btn)
lt = rd(f"{leg}/hero.ui")
assert "ahievements_button" not in lt
# первые объекты в файле рисуются ПОВЕРХ остальных (фон окна — последний), поэтому кнопку вставляем в начало
i = lt.index("gui_object_begin")
wr(f"{out}/hero.ui", lt[:i] + btn + lt[i:])

# forms.txt: блоки форм (form= как в WotN/DS)
f = rd(f"{mod}/forms.txt")
add = ""
if "achievements {" not in f:
    add += ("\nachievements {\n    description=Achievements book\n    ui=achievements.ui\n    form=achievements\n"
            "    3360x945=achievements_3360x945.ui\n}\n"
            "\nnew_achievement {\n    description=New achievement popup\n    ui=new_achievement.ui\n    form=new_achievement\n"
            "    3360x945=new_achievement_3360x945.ui\n}\n")
wr(f"{out}/forms.txt", f.rstrip("\n") + "\n" + add)
print("forms blocks added:", bool(add), "| hero button at", BX, BY)
