# 🗂️ Структура игр серии

Источник: `kfs_listing.csv` (содержимое всех `.kfs` Legend EE), `full_listing.csv`, `top_levels.txt`
из `tools/dump_structure.ps1`, присланные владельцем (2026-11-24). Пометка ❓ — предположение.

## Главный факт: `.kfs` — это zip
Ресурсы игр хранятся в архивах `.kfs`. Они открываются любым архиватором (владелец проверил) и читаются
как zip, в том числе из PowerShell (`System.IO.Compression.ZipFile`), **без распаковки и переименования**.
Скрипт списка содержимого — `tools/list_kfs.ps1`.

## King's Bounty: The Legend EE (`...\Blefonix Studios\KB The Legend EE`)
Файлов всего 5385. Игра **не** распакована; распакованные `loc_data`, `models`, `sky`, `sounds`, `textures`
на рабочем столе владельца — результат ручной распаковки `.kfs`.

### `data\*.kfs`
| Архив | Размер | Что внутри |
|---|---|---|
| `data.kfs` | 46 МБ | **все `.ui`** (104 шт.), `resolutions.txt`, `.atom` (2648), `.ptb` (1470), `.csh` (1068), `.bma` (508), `.cms` (356), `.track` (124), `.ani`, `.fnt`, 16 `.txt`, `.cfg`, 28 `.dds`, 8 `.png` |
| `interface_textures.kfs` | 142 МБ | 204 `.png` — картинки интерфейса (например `mainpanel_bg_1680.png`) |
| `textures.kfs` | 324 МБ | `.dds` 1950, `.png` 88, `.tga` 40, `.bmp` 1 |
| `models.kfs` | 56 МБ | `.bms` 1771, `.cms` 1188, `.bma` 651, `.bsa` 2, `.bmc` 1 |
| `animation.kfs` | 102 МБ | `.bsa` 2688, `.bft` 3 |
| `sounds.kfs` | 172 МБ | `.wav` 2329, `.csv`, `.sfk`, `.gpk` |
| `sky.kfs` | 52 МБ | `.bms` 15, `.dds` 84 |
| `loc_data.kfs` | 8 МБ | озвучка вступления `.ogg` ×4, логотипы `.png` ×3 |

Рядом лежат обычные файлы: `app.ini`, `default.ini`, `game.ini`, `fonts.cfg`, `calibri.ttf`, папки `mods\`, `music\`, `video\`.

### `sessions\base\` (5271 файл — не в архивах)
`.loc` 2172, `.lng` 1613, `.chat` 405, `.act` 347, `.lu` 254, `.stream` 183 (до 114 МБ — текстуры локаций),
`.qst` 122 (квесты), `.hero` 90, `.lua` 43, `.txt` 51.
Папка `ses\` — игровые скрипты и настройки: `camera.txt`, `forms.txt`, `config.txt`, `autoconfig.txt`, `arena.lua`, `spells.lua`, `skills.txt`, `items.txt` и др.

### Как игра выбирает интерфейс
- `data.kfs\resolutions.txt` (44 байта) — таблица `соотношение=логическое разрешение`.
- `sessions\base\ses\forms.txt` — список окон; для каждого `ui=` по умолчанию и варианты по разрешению (`1680x945=...`).
- Окна без варианта под разрешение берут `ui=` по умолчанию (рассчитан на 4:3) — на 32:9 такое окно встаёт у **левого** края.
  Так уезжает журнал заданий (`quests_journal.ui`, 5,7 КБ, вариантов нет). Нужны 3360×945-версии всех таких окон.
- Мод `data\mods\<имя>\` перекрывает `forms.txt` и `resolutions.txt`.

### `.ui` в `data.kfs` (вариантов под широкие разрешения нет, кроме отмеченных)
Окна без вариантов: `hero`, `book`, `quests_journal`, `options`, `records`, `save_load`, `menu`, `casket`, `bigmap`, `buy*`,
`sale_items`, `sell_scrolls`, `use_items`, `throwout`, `drop_items`, `deletion`, `reserve`, `separation`, `moving*`,
`level_up`, `sp_level_up`, `dialog`, `splash_*`, `victory_*`, `lose_*`, `dlg_chesspiece`, `info_chesspiece`.
С вариантами (1280×1024, 1680×1050): `arena`, `map`, `start`, `new_game`, `credits`, `intro`, `loading`, `town_1`.
Карты локаций: `<локация>.ui` и `<локация>_clouds.ui` (облака на глобальной карте).

## Остальные игры серии
Все на том же движке, тот же набор `.kfs`.

| Игра | Папка | Размер, файлов | Особенности |
|---|---|---|---|
| Warriors of the North | `King's Bounty Warriors of the North` | 5868 | `data\*.kfs` + патчи `patch_001..003.kfs`, `declarations.kfs`; сессии `addon`, `ice_and_fire` (`ses.kfs`, локализации `*_loc_ses_iaf.kfs`) |
| Crossworlds | `Kings Bounty - Crossworlds` | 3962 | редактор карт `editor\` (3310 файлов), сессии `addon`, `champion`, `defender`, `orcs` |
| Crossworlds: Red Sands | `Kings Bounty Crossworlds - red sands` | 5286 | **`.ui` и `forms.txt` лежат обычными файлами** в `sessions\red_sands\red_sands_ses\schemes\` и `...\config\`; есть **официальные `start_1680x945.ui` и `town_1680x945.ui`** — образец 16:9 от разработчиков |
| Dark Side | `Kings Bounty Dark Side` | 7258 | `data.kfs` 11 МБ, `textures_game.kfs`, отдельные локализации (`loc_data_eng/ger/pol.kfs`), `sessions\darkside\ses.kfs`, 4705 `.wav` лежат вне архива |

## Ещё не изучено ❓
- Байтовые форматы `.bms/.bma/.bsa/.cms/.atom/.ptb/.csh/.stream`.
- Какие поля интерфейс получает от движка (список имён в `.ui` — что можно показывать на панели).
- Откуда игра берёт картинки мода (папка мода или только `.kfs`).
