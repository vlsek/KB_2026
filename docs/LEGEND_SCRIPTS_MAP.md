# 🗺️ Карта скриптов Legend (`sessions\base\ses`) и сравнение с WotN (агент 4)

Legend: 3472 файла, 60 МБ — `.loc` 2172, `.chat` 405, `.act` 347, `.lu` 254, `.qst` 122, `.hero` 90, `.lua` 43, `.txt` 34, `.strg` 5.
Все `.lua`/`.txt` — читаемый текст (UTF-8 или cp1251 — проверять кодировку при правке!).

## Lua по зонам
| Зона | Файлы (размер) | Что там | Идеи |
|---|---|---|---|
| Бой | `arena.lua` 112К, `pawn.lua` 34К, `combat_log.lua` 12К | урон, ход, лог боя | ускорение анимаций, подробный лог, ИИ |
| Магия | `spells.lua` 115К, `spells_common` 43К, `spells_power` 34К, `spells_hint` 36К, `spell_effects` 21К | заклинания и их тексты | баланс, новые заклинания (из WotN: `spells_adv`, `new_spells.txt`) |
| Умения юнитов | `special_attacks.lua` 72К, `unit_features.lua` 38К, `unit_morale.lua` | способности существ | в WotN разнесены на `unit_special_attacks*`, `unit_features_master/slave/ondamage` |
| Герой | `logic_hero.lua` 19К, `skills.lua` 15К, `item_fight.lua` 16К, `item_use.lua` | навыки, предметы | новые навыки/предметы из серии |
| Боссы/духи | `boss.lua` 24К, `spirit_*.lua` | скрипты боссов | — |
| Мир | `logic_*.lua`, `armygen`, `armywalk`, `boxes`, `transport`, `quest_*` | армии на карте, сундуки, квесты | QoL: автосбор, мини-карта, журнал |
| Тексты | `textgen`, `items_hint`, `spells_hint`, `special_hint` | генерация подсказок | читаемость, русификация |

## Конфиги
- `default.ini` — графика: тени (`r_shadowmap_landscape 0`), `r_vsync 0`, `r_refreshrate 100`, `r_fsaa 0`, фильтр `r_filter 2` (аниз. 2×; доступно до 16×), `r_picmip 0`, шейдеры `r_path ps20`, вода `r_water 1`.
- `game.ini` — пользовательские: `screenresoultionx/y 0` (авто), `shadowresolution 1024`, `r_shadowmap_4sample 1`, `r_water_quality 2`, `r_clip_distance 0`, `streaming 0`.
- `camera.txt` — это уже **наша правка** (комментарии с вариантами): `DIST_MAX=36`, `FOV=50`, `ZFAR=150`, `ClipDist` с таблицами для Big/Average/Small.

Быстрые графические выигрыши без кода: `r_filter 5` (16× анизотропия), `shadowresolution 2048–4096`, `r_shadowmap_landscape 1`, `r_vsync 1`. Всё требует проверки в игре.

## Legend → WotN: что изменилось (по `.lua`)
- Новых файлов в WotN: 17 (`addon_*`, `rune_knowledge`, `subturns`, `visa*`, `cutscenes`, `spells_adv`, `unit_special_attacks*`, `unit_features_*`, `boss_add`, `addon_pet`).
- Изменено: 30 файлов, в т.ч. `arena.lua` ×2,4, `spells.lua` ×2,2, `boss.lua` ×4,5, `item_use.lua` ×10, `special_hint.lua` ×4,4.
- Размер `items.txt`: 292 КБ → 638 КБ, `spells.txt` 51 → 78 КБ, `skills.txt` 22 → 29 КБ.
- Вывод: **WotN-скрипты нельзя копировать целиком** — они завязаны на аддон-механики (руны, питомцы, подходы `subturns`). Переносить точечно: функции + нужные записи в `.txt`.
- `unit_features.lua` в WotN, наоборот, сжат с 38 КБ до 8 КБ — логика переехала в `unit_features_master/slave/ondamage`.
