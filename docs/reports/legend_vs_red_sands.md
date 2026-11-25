# Сравнение игр серии

| Игра | Файлов (с содержимым .kfs) | Размер |
|---|---|---|
| legend | 22962 | 7183.2 МБ |
| red_sands | 36832 | 8186.0 МБ |

## Расширения по играм (число файлов)

| Ext | legend | red_sands |
|---|---|---|
| `(нет)` | 0 | 1 |
| `.act` | 348 | 635 |
| `.ani` | 48 | 50 |
| `.atom` | 2654 | 4067 |
| `.bak` | 2 | 0 |
| `.bft` | 3 | 9 |
| `.bik` | 11 | 17 |
| `.bin` | 0 | 1 |
| `.bma` | 1161 | 1419 |
| `.bmc` | 1 | 1 |
| `.bmp` | 1 | 0 |
| `.bms` | 1789 | 1896 |
| `.bp` | 1 | 0 |
| `.bsa` | 2690 | 3304 |
| `.cfg` | 2 | 1 |
| `.chat` | 406 | 779 |
| `.cms` | 1544 | 1711 |
| `.csh` | 1068 | 1132 |
| `.csv` | 9 | 9 |
| `.dat` | 3 | 3 |
| `.dds` | 2067 | 2386 |
| `.dll` | 7 | 6 |
| `.envlp` | 5 | 5 |
| `.et` | 0 | 2 |
| `.exe` | 2 | 3 |
| `.f` | 1 | 1 |
| `.fmk` | 4 | 4 |
| `.fnt` | 4 | 4 |
| `.gpk` | 1 | 0 |
| `.hero` | 90 | 491 |
| `.htm` | 0 | 9 |
| `.ico` | 1 | 0 |
| `.ini` | 4 | 4 |
| `.json` | 2 | 0 |
| `.kfs` | 11 | 22 |
| `.lng` | 1625 | 1691 |
| `.loc` | 2172 | 3341 |
| `.lu` | 254 | 322 |
| `.lua` | 97 | 268 |
| `.mod` | 1 | 0 |
| `.msk` | 11 | 6 |
| `.ogg` | 41 | 49 |
| `.ogm` | 6 | 6 |
| `.pdf` | 2 | 2 |
| `.png` | 328 | 5258 |
| `.ps1` | 1 | 0 |
| `.ptb` | 1470 | 1885 |
| `.qst` | 122 | 897 |
| `.rtf` | 0 | 1 |
| `.sfk` | 6 | 0 |
| `.sqlite` | 1 | 0 |
| `.stream` | 183 | 215 |
| `.strg` | 5 | 7 |
| `.sub` | 2 | 6 |
| `.tga` | 40 | 40 |
| `.track` | 124 | 161 |
| `.ttf` | 1 | 0 |
| `.txt` | 81 | 312 |
| `.ui` | 120 | 154 |
| `.vmsp` | 0 | 6 |
| `.wav` | 2329 | 4233 |

## Сигнатуры форматов (первые 4 байта) у обычных файлов

Одинаковые сигнатуры у одного расширения в разных играх - формат, скорее всего, тот же. У файлов из архивов сигнатур в манифесте нет.

| Ext | legend | red_sands |
|---|---|---|
| `.act` | `02000000`x347 | `02000000`x73 |
| `.ani` | - | `52494646`x4 |
| `.atom` | - | `6d61696e`x335 |
| `.bak` | `fffe2f00`x1, `3d3d6865`x1 | - |
| `.bik` | `42494b69`x11 | `42494b69`x17 |
| `.bma` | - | `06000400`x18 |
| `.cfg` | `fffe2f00`x1 | - |
| `.chat` | `02000000`x405 | `02000000`x178 |
| `.csv` | `efbbbf22`x2 | `40484541`x1 |
| `.dat` | `496e6e6f`x1 | `496e6e6f`x1 |
| `.dds` | - | `44445320`x2 |
| `.dll` | `4d5a9000`x7 | `4d5a9000`x6 |
| `.et` | - | `6e616d65`x2 |
| `.exe` | `4d5a9000`x1, `4d5a5000`x1 | `4d5a9000`x2, `4d5a5000`x1 |
| `.hero` | `02000000`x90 | `02000000`x95 |
| `.htm` | - | `68656c70`x9 |
| `.ico` | `00000100`x1 | - |
| `.ini` | `5b2e5368`x1, `73657473`x1, `23232323`x1 | `73657466`x2, `73657473`x1, `23232323`x1 |
| `.json` | `7b0d0a20`x2 | - |
| `.kfs` | `504b0304`x11 | `504b0304`x22 |
| `.lng` | `fffe6300`x1218, `fffe7100`x319, `fffe2f00`x49 | `fffe6300`x185, `fffe7100`x30, `fffe2f00`x7 |
| `.loc` | `02000000`x2067, `06000000`x105 | `02000000`x288, `06000000`x88 |
| `.lu` | `02000000`x254 | `02000000`x49 |
| `.lua` | `66756e63`x22, `0d0a6675`x6, `2d2d202a`x4 | `66756e63`x23, `2d2d202a`x8, `2d2d2a2a`x3 |
| `.ogg` | `4f676753`x37 | `4f676753`x48 |
| `.ogm` | `4f676753`x6 | `4f676753`x6 |
| `.pdf` | `25504446`x2 | `25504446`x2 |
| `.png` | `89504e47`x12 | `89504e47`x3194 |
| `.ps1` | `0a706172`x1 | - |
| `.qst` | `02000000`x122 | `02000000`x207 |
| `.rtf` | - | `7b5c7274`x1 |
| `.sqlite` | `53514c69`x1 | - |
| `.stream` | `0df0adde`x183 | `0df0adde`x204, `3c6f7263`x9 |
| `.strg` | `736c6362`x5 | `736c6362`x1, `02000000`x1 |
| `.sub` | - | `40484541`x1 |
| `.ttf` | `00010000`x1 | - |
| `.txt` | `0d0a2f2f`x8, `efbbbfd0`x7, `67616d65`x2 | `636f6e73`x13, `0d0a636f`x8, `0d0a0d0a`x6 |
| `.ui` | `6775695f`x12 | `6775695f`x17 |

## legend -> red_sands

Сопоставление по имени файла (папка и архив не учитываются).

- Есть в обеих, содержимое одинаковое: **16886**
- Есть в обеих, содержимое отличается: **2610**
- Нет в legend вообще (кандидаты на перенос): **17233** (4120.8 МБ)

### Новое в red_sands: где лежит и какого типа (топ 40 по размеру)

| Папка или архив | Ext | Файлов | Размер |
|---|---|---|---|
| `sessions/addon/locations` | `.stream` | 74 | 2526.6 МБ |
| `sessions/champion/locations` | `.stream` | 10 | 302.7 МБ |
| `sessions/red_sands/locations` | `.stream` | 17 | 219.4 МБ |
| `sessions/orcs/locations` | `.stream` | 8 | 183.7 МБ |
| `data/interface_textures.kfs` | `.png` | 1226 | 129.5 МБ |
| `data/sounds.kfs` | `.wav` | 1892 | 128.2 МБ |
| `data/animation.kfs` | `.bsa` | 614 | 101.1 МБ |
| `sessions/defender/locations` | `.stream` | 4 | 77.2 МБ |
| `data/textures.kfs` | `.dds` | 238 | 53.1 МБ |
| `data/music` | `.ogg` | 12 | 45.1 МБ |
| `sessions/red_sands` | `.kfs` | 2 | 37.5 МБ |
| `sessions/red_sands/red_sands_data.kfs` | `.png` | 452 | 25.4 МБ |
| `.` | `.kfs` | 2 | 22.8 МБ |
| `sessions/addon/ses.kfs` | `.loc` | 816 | 22.5 МБ |
| `sessions/orcs` | `.kfs` | 2 | 21.3 МБ |
| `.` | `.pdf` | 2 | 16.3 МБ |
| `data/models.kfs` | `.bma` | 155 | 14.1 МБ |
| `sessions/red_sands/red_sands_ses.kfs` | `.loc` | 313 | 12.8 МБ |
| `sessions/red_sands/red_sands_ses/locs` | `.loc` | 313 | 12.8 МБ |
| `orcs.kfs` | `.png` | 82 | 11.8 МБ |
| `sessions/orcs/orcs.kfs` | `.png` | 82 | 11.8 МБ |
| `data/models.kfs` | `.bms` | 107 | 11.5 МБ |
| `manual/tutorial/locations/sunset_isle` | `.stream` | 1 | 11.2 МБ |
| `sessions/orcs/orcs.kfs` | `.loc` | 175 | 8.2 МБ |
| `orcs.kfs` | `.loc` | 169 | 8.2 МБ |
| `sessions/red_sands/red_sands_data.kfs` | `.dds` | 49 | 8.1 МБ |
| `editor/thumbnails` | `.png` | 3064 | 8.0 МБ |
| `sessions/addon` | `.kfs` | 4 | 6.5 МБ |
| `sessions/champion` | `.kfs` | 2 | 5.6 МБ |
| `data/interface/video` | `.ogm` | 2 | 4.8 МБ |
| `data/video` | `.ogm` | 2 | 4.2 МБ |
| `.` | `.dll` | 2 | 4.1 МБ |
| `sessions/red_sands/red_sands_data.kfs` | `.bma` | 42 | 3.9 МБ |
| `data/textures.kfs` | `.png` | 14 | 3.1 МБ |
| `sessions/champion/champion.kfs` | `.loc` | 112 | 2.6 МБ |
| `.` | `.exe` | 1 | 2.2 МБ |
| `orcs.kfs` | `.dds` | 13 | 2.0 МБ |
| `sessions/orcs/orcs.kfs` | `.dds` | 13 | 2.0 МБ |
| `editor/fileset/Hero. Searcher Bill Gillbert/Data/Models` | `.bma` | 9 | 1.9 МБ |
| `sessions/addon/loc_ses.kfs` | `.lng` | 367 | 1.8 МБ |

### Новые скрипты и данные в red_sands (топ 40 по размеру)

- `sessions/red_sands/red_sands_ses/scripts/addon_special_attacks.lua` (314608 Б)
- `sessions/red_sands/red_sands_ses.kfs!/scripts/addon_special_attacks.lua` (314481 Б)
- `sessions/red_sands/red_sands_ses.kfs!/scripts/addon_unit_features.lua` (232751 Б)
- `sessions/red_sands/red_sands_ses/scripts/addon_unit_features.lua` (228764 Б)
- `editor/editor_containers.txt` (138422 Б)
- `editor/editor_atoms.txt` (111188 Б)
- `editor/editor_levels.txt` (102571 Б)
- `sessions/red_sands/red_sands_ses.kfs!/config/medals.txt` (86163 Б)
- `sessions/red_sands/red_sands_ses/config/medals.txt` (86163 Б)
- `editor/editor_struids.txt` (84124 Б)
- `sessions/red_sands/red_sands_ses.kfs!/scripts/battle_akademy.lua` (67060 Б)
- `sessions/red_sands/red_sands_ses/scripts/battle_akademy.lua` (67060 Б)
- `orcs.kfs!/battle_akademy.lua` (64388 Б)
- `sessions/orcs/orcs.kfs!/battle_akademy.lua` (61446 Б)
- `orcs.kfs!/medals.txt` (59540 Б)
- `sessions/addon/ses.kfs!/medals.txt` (59540 Б)
- `sessions/orcs/orcs.kfs!/medals.txt` (59540 Б)
- `defender.kfs!/properties.txt` (57778 Б)
- `sessions/defender/defender.kfs!/properties.txt` (57778 Б)
- `sessions/orcs/orcs.kfs!/new_spells.lua` (57027 Б)
- `sessions/red_sands/red_sands_ses.kfs!/chats/2107357712.chat` (56909 Б)
- `sessions/red_sands/red_sands_ses/chats/2107357712.chat` (56909 Б)
- `sessions/red_sands/red_sands_ses.kfs!/config/companion.txt` (55469 Б)
- `sessions/red_sands/red_sands_ses/config/companion.txt` (55469 Б)
- `orcs.kfs!/new_spells.lua` (54592 Б)
- `data/data.kfs!/time_guard.atom` (53396 Б)
- `editor/dialogs/editor_dialogs_embryo.txt` (52754 Б)
- `sessions/red_sands/red_sands_ses.kfs!/scripts/addon_spells.lua` (51967 Б)
- `sessions/red_sands/red_sands_ses/scripts/addon_spells.lua` (51967 Б)
- `sessions/champion/champion.kfs!/properties.txt` (50186 Б)
- `sessions/red_sands/red_sands_ses.kfs!/exp_system/exp_system.lua` (49797 Б)
- `sessions/red_sands/red_sands_ses/exp_system/exp_system.lua` (49797 Б)
- `editor/dialogs/editor_dialogs_light.txt` (49265 Б)
- `defender.kfs!/medals.txt` (46810 Б)
- `sessions/defender/defender.kfs!/medals.txt` (46810 Б)
- `orcs.kfs!/addon_boss.lua` (45245 Б)
- `sessions/orcs/orcs.kfs!/addon_boss.lua` (45245 Б)
- `sessions/red_sands/red_sands_ses.kfs!/scripts/addon_boss.lua` (45245 Б)
- `sessions/red_sands/red_sands_ses/scripts/addon_boss.lua` (45245 Б)
- `sessions/addon/ses.kfs!/addon_boss.lua` (44918 Б)

### Те же имена, но другое содержимое: скрипты и данные (топ 40 по размеру)

| Файл в red_sands | Байт | Байт в legend |
|---|---|---|
| `sessions/red_sands/red_sands_ses.kfs!/config/items.txt` | 647426 | 292090 |
| `sessions/red_sands/red_sands_ses/config/items.txt` | 647426 | 292090 |
| `sessions/orcs/orcs.kfs!/items.txt` | 538283 | 292090 |
| `orcs.kfs!/items.txt` | 538076 | 292090 |
| `orcs.kfs!/embryos.txt` | 472242 | 346271 |
| `sessions/orcs/orcs.kfs!/embryos.txt` | 472242 | 346271 |
| `sessions/champion/champion.kfs!/embryos.txt` | 465489 | 346271 |
| `defender.kfs!/embryos.txt` | 463990 | 346271 |
| `sessions/defender/defender.kfs!/embryos.txt` | 463990 | 346271 |
| `sessions/red_sands/red_sands_ses.kfs!/config/embryos.txt` | 463989 | 346271 |
| `sessions/red_sands/red_sands_ses/config/embryos.txt` | 463989 | 346271 |
| `sessions/addon/ses.kfs!/embryos.txt` | 463982 | 346271 |
| `sessions/champion/champion.kfs!/items.txt` | 390820 | 292090 |
| `defender.kfs!/items.txt` | 390418 | 292090 |
| `sessions/defender/defender.kfs!/items.txt` | 390418 | 292090 |
| `sessions/addon/ses.kfs!/items.txt` | 390400 | 292090 |
| `sessions/red_sands/red_sands_ses/scripts/arena.lua` | 218632 | 111953 |
| `sessions/red_sands/red_sands_ses.kfs!/scripts/arena.lua` | 216295 | 111953 |
| `sessions/red_sands/red_sands_ses.kfs!/config/sounds.csv` | 171118 | 130682 |
| `sessions/red_sands/red_sands_ses/config/sounds.csv` | 171118 | 130682 |
| `data/sounds.kfs!/sounds.csv` | 170405 | 130682 |
| `sessions/orcs/orcs.kfs!/arena.lua` | 161629 | 111953 |
| `orcs.kfs!/arena.lua` | 159750 | 111953 |
| `sessions/champion/champion.kfs!/arena.lua` | 134476 | 111953 |
| `defender.kfs!/arena.lua` | 131493 | 111953 |
| `sessions/defender/defender.kfs!/arena.lua` | 131493 | 111953 |
| `sessions/addon/ses.kfs!/arena.lua` | 130168 | 111953 |
| `sessions/red_sands/red_sands_ses.kfs!/scripts/spells.lua` | 126716 | 115464 |
| `sessions/red_sands/red_sands_ses/scripts/spells.lua` | 126716 | 115464 |
| `sessions/addon/ses.kfs!/spells.lua` | 121217 | 115464 |
| `sessions/red_sands/red_sands_ses/scripts/special_attacks.lua` | 88223 | 72175 |
| `sessions/red_sands/red_sands_ses.kfs!/scripts/special_attacks.lua` | 88215 | 72175 |
| `sessions/addon/ses.kfs!/special_attacks.lua` | 72382 | 72175 |
| `sessions/red_sands/red_sands_ses.kfs!/scripts/spells_common.lua` | 72152 | 43535 |
| `sessions/red_sands/red_sands_ses/scripts/spells_common.lua` | 72152 | 43535 |
| `sessions/champion/champion.kfs!/spells.txt` | 63351 | 50573 |
| `data/data.kfs!/death.atom` | 55541 | 55536 |
| `sessions/red_sands/red_sands_ses/config/spells.txt` | 55503 | 50573 |
| `sessions/red_sands/red_sands_ses.kfs!/config/spells.txt` | 55479 | 50573 |
| `orcs.kfs!/spells.txt` | 55163 | 50573 |
