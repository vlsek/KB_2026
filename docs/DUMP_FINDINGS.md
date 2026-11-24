# 🔎 Находки по дампам игр серии (агент 5)

Источник: `docs/dumps/2026-11-24_gog_all/` (`summary.csv`, `top_levels.txt`, `full_listing.csv.gz`).
Все игры — версии GOG. Пометка ❓ — гипотеза по именам/размерам, не проверено содержимым.

## Что в дампе
| Папка | Игра | Файлов | Заметки |
|---|---|---|---|
| `KB The Legend EE` | The Legend (оригинал, EE) | 5385 | `sessions\base` **распакован** |
| `Kings Bounty - Crossworlds` | Crossworlds (+ Armored Princess? ❓) | 3962 | есть `Editor.exe` и `editor\fileset` |
| `Kings Bounty Crossworlds - red sands` | Red Sands (Красные пески) | 5286 | сессия `red_sands` распакована, есть редактор |
| `King's Bounty Warriors of the North` | Воин Севера | 5868 | сессии в `.kfs` |
| `Kings Bounty Dark Side` | Тёмная сторона | 7258 | сессии в `.kfs`, звуки распакованы (4705 `.wav`) |

⚠️ **Принцессы в доспехах (Armored Princess) отдельной папкой нет.** В Crossworlds есть `KBPrincessGDF.dll` и герой `Princess Amely` в `editor\fileset` ❓ — возможно, база Princess уже внутри. Владельцу уточнить, ставилась ли она отдельно.

## Главное
1. **Общий движок подтверждён.** Во всех играх одинаковый набор архивов `.kfs`: `data`, `models`, `textures`, `animation`, `sounds`, `interface_textures`, `sky`, `loc_data`. Значит один распаковщик и один подход подойдут для всей серии.
2. **В Legend уже распакованы игровые данные** (`sessions\base\ses`): 43 `.lua`, 254 `.lu`, 347 `.act`, 122 `.qst`, 90 `.hero`, 405 `.chat`, `.loc`, `.lng`. Скрипты читаемы и правятся без распаковки — это основной плацдарм для геймплейных модов. Есть `camera.txt`, `forms.txt`.
3. **В `Legend\data\mods` уже лежат моды:** `16_9-nsf` (наш 32:9), `KBMaster_1.3.1_for_1.7.kfs`, `mod_17_master_101_familiar.kfs`, `mod_17_Master_129_add_exp_limit.kfs`. Формат мода-архива `.kfs` в `data\mods` работает ❓ — это упрощает упаковку.
4. **Crossworlds и Red Sands содержат официальный редактор** (`Editor.exe`, `editor\fileset` ≈ 3300 файлов, `editor\help`, `.atom`-файлы героев). Это документированный формат данных движка — ключ к пониманию `.atom/.qst/.hero`.
5. **Red Sands распакован и мультиразрешён:** `sessions\red_sands\red_sands_ses\schemes\*.ui` есть в вариантах `1280x1024`, `1680x1050`, `1680x945`. Хорошая эталонная база для генератора `.ui` (Issue #2).
6. ✅ **Достижения найдены** (агент 4): `ses.kfs` WotN → `achievements.txt`, подробности в [ACHIEVEMENTS.md](ACHIEVEMENTS.md). Ранее: **не лежат отдельными файлами:** поиск `achiev|trophy|stats` по путям даёт ноль. `steam_api.dll` есть в Dark Side и WotN, в Legend нет. Значит либо достижения только Steam-овые (в GOG-версии не работают), либо внутри `.kfs`/`.lua`. Нужна распаковка `.kfs` Dark Side / WotN и поиск по тексту.
7. **Конфиги:** `data\default.ini`, `game.ini`, `app.ini`, `fonts.cfg` одни и те же имена во всех играх. Сравнить их — самый быстрый путь к графическим настройкам.
8. **`.stream`-файлы** (4.5–6.3 ГБ на игру, 183–251 шт.) — самая большая часть данных ❓ (видимо данные карт/сессий). Формат не изучен.
9. **Dark Side и Legend EE используют `libcef.dll`** ❓ — часть интерфейса, возможно, на HTML/Chromium.

## Следующие шаги
- Найти/написать распаковщик `.kfs`, проверить на `loc_data.kfs` Legend (самый маленький, 7 МБ).
- Распаковать `declarations.kfs`, `data.kfs`, `ses.kfs` у Dark Side и WotN; grep по `achiev`.
- Сравнить `default.ini` / `game.ini` / `camera.txt` / `forms.txt` между играми.
- Манифесты со сверкой первых байт: `tools/kb_manifest.py` и `tools/kb_compare.py` (ветка `agent/claude/cross-game-manifest`).
