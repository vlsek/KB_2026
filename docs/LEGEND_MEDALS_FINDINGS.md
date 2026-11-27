# Медали-ачивки в Legend: что выяснено (агент 1, 2026-11-27)

## Подтверждено в игре
- Нативной формы ачивок в `kb.exe` нет (кода медалей нет) -> ачивки только скриптами Lua.
- Слоты под медали в окне героя (6 кнопок `slot_13..18`, `mods/medal-slots-ui`) отображаются; клики проходят как у кнопок.
- Предмет-медаль в формате Legend (`category=o`, `race=neutral`, `hint_config=object_item`, `mods {}`, `params {}`) работает. **`propbits=medal` движок молча отвергает** (предмет не добавляется) - использовать `quest`.
- Стартовые предметы через `hero.txt` -> `items { имя=1 }` работают (медаль в рюкзаке с начала новой игры). Выдача из Lua `Logic.hero_add_item(name)` работает.
- Иконка: PNG-файлы мода не подходят, иконки предметов берутся из атласов. Родная `heroitem_quest_medal.png` показалась; тип в подсказке «Квестовый» при `propbits=quest`. При `rare` писалось «Unknow item type!».
- Названия типов: `rus_items_base.lng` -> `itm_weapon/armor/artefact/boots/regalia/shield/helmet/belt/quest/resource/map/usual/wife/child/diamond/recept`. Своего типа «Медаль» нет, добавлять строку в lng можно, но надо знать, как движок выбирает тип (по propbits).
- KBMaster 1.3.1 держит свои копии скриптов/hero.txt/items_monster.txt/itextures.dat; при нём правки loose-файлов игнорируются. Правки только через `Mod:insert` и инклюды `master_itm_NNN.txt`, `master_cfg_NNN.txt`, `master_tex_NNN.txt` (+ `texNNN.dds`, номера 101-200, реестр kingsbounty.ru). Хуки `KBMaster.PREDEF.arena_on_combat_end`, `logic_generation_hero`, `logic_regular_script`.

## Lua API (проверено)
Есть: `Game.GVNum/GVNumInc/GVSNum`, `Game.MessageBox` (заголовок «Ошибка»), `Game.InfoHint`, `Game.InvokeMsgBox`, `Logic.hero_add_item/hero_lu_item/hero_lu_var`. Нет: `Logic.hero_remove_item`, `Rec`. Lua 5.0 (нет `#`). Читаются счётчики `damage_magic`, `battles_count`, `enemy_units_killed`, `res_crystals_received`, `runes_might_received`.

## Формат itextures.dat
ASCII, CRLF, блоки `TEX1..TEX11`; каждый `block { filename, in_tex_pos, in_tex_size, geom_pos, geom_size, mask=offset,len }` (иконка предмета 52x52, mask len 338). Атлас - DDS 32 бита (мод фамильяра: `tex101.dds` 512x512 BGRA с мип-уровнями). `heroitem_quest_medal.png` в блоке на позиции (52,779).

## Карта-панель (статистика)
Поля `rec_*` значений не отдают (шаблоны подписей), `hero_*` - подписи. Ждём результат пробы `probe2` (`hero_*_num`).

## План (пожелания владельца 2026-11-27)
1. Отдельные слоты только для медалей-ачивок; медаль надевается автоматически, снять нельзя.
2. При повышении ранга медаль заменяется автоматически (`_1.._4`).
3. Подсказка слота: какая медаль может лежать и за что выдаётся.
4. Всплывающее окно «медаль получена».
Техника: слоты не как предметы, а как собственная отрисовка в hero.ui + Lua-флаги `kb26_med_<имя>=ранг`; подсказки через lng-ключи; окно через InvokeMsgBox/InfoHint; своя иконка - атлас `tex1NN.dds` через KBMaster.

## Подтверждено владельцем (2026-11-27, дописал агент 5 по консоли `kb_slot_test2.ps1`)
- Свой тип слота `mslot` работает: в `config.txt` в `propbits` добавлен следующий свободный бит (`mslot=0x1000000`, последний занятый - `artefact=0x800000`), в `hero.txt` слоты `13..18=mslot` + запись в `slot_bgs`, медаль `propbits=mslot`. Медаль надевается **только** в слоты 13-18 и не лезет в слоты артефактов. Откат: `kb_slot_test2.ps1 -Undo`, затем `kb_slot_test1.ps1 -Undo`.
- Скрипт `kb_slot_test2.ps1` в архивах агента 1 не пришёл (описание в консоли владельца); в репо будет воспроизведён как `mods/medal-slots` (агент 5).
- Не решено: автонадевание (в Lua Legend `Logic.hero_lu_item_on_body` не встречается - нужна проба API), запрет снятия, замена при повышении ранга (нет `Logic.hero_remove_item`; кандидат - `Logic.hero_lu_item(имя,"count",0)`), подсказка слота (ключ lng), окно «медаль получена».
