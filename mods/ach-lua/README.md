# ach-lua - достижения в Legend через Lua (агент 1)

Статус: needs-test (v0.3 работает: медаль выдаётся; логика условий - заглушка).
- `payload/ach.lua` - функция `kb2026_check_ach(tag)`, вставляется в `logic_hero.lua` после `scn_hero_takebox`.
- `install.ps1` / `uninstall.ps1` - от администратора; бэкап `logic_hero.lua.kb2026ach.bak`.
- `tests/` - пробы: `kb_plain_item_test*.ps1` (предмет-медаль в реальном формате), `kb_medal_fix1.ps1` (родная иконка + propbits=quest), `probe_v4.lua`.
Важно: при установленном KBMaster правки loose `logic_hero.lua`/`hero.txt` игнорируются - итоговый вариант делать через `Mod:insert`. См. docs/LEGEND_MEDALS_FINDINGS.md.
