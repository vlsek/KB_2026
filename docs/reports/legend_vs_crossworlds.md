# Сравнение игр серии

| Игра | Файлов (с содержимым .kfs) | Размер |
|---|---|---|
| legend | 22962 | 7183.2 МБ |
| crossworlds | 31681 | 8138.2 МБ |

## Расширения по играм (число файлов)

| Ext | legend | crossworlds |
|---|---|---|
| `(нет)` | 0 | 1 |
| `.act` | 348 | 430 |
| `.ani` | 48 | 50 |
| `.atom` | 2654 | 3241 |
| `.bak` | 2 | 0 |
| `.bft` | 3 | 9 |
| `.bik` | 11 | 17 |
| `.bin` | 0 | 1 |
| `.bma` | 1161 | 1365 |
| `.bmc` | 1 | 1 |
| `.bmp` | 1 | 0 |
| `.bms` | 1789 | 1896 |
| `.bp` | 1 | 0 |
| `.bsa` | 2690 | 3304 |
| `.cab` | 0 | 154 |
| `.cfg` | 2 | 1 |
| `.chat` | 406 | 372 |
| `.cms` | 1544 | 1671 |
| `.csh` | 1068 | 1132 |
| `.csv` | 9 | 7 |
| `.dat` | 3 | 2 |
| `.dds` | 2067 | 2318 |
| `.dll` | 7 | 7 |
| `.envlp` | 5 | 5 |
| `.et` | 0 | 2 |
| `.exe` | 2 | 4 |
| `.f` | 1 | 1 |
| `.fmk` | 4 | 4 |
| `.fnt` | 4 | 4 |
| `.gpk` | 1 | 0 |
| `.hero` | 90 | 196 |
| `.htm` | 0 | 9 |
| `.ico` | 1 | 0 |
| `.ini` | 4 | 4 |
| `.json` | 2 | 0 |
| `.kfs` | 11 | 13 |
| `.lng` | 1625 | 644 |
| `.loc` | 2172 | 2358 |
| `.lu` | 254 | 219 |
| `.lua` | 97 | 122 |
| `.mod` | 1 | 0 |
| `.mp3` | 0 | 56 |
| `.msk` | 11 | 6 |
| `.ogg` | 41 | 49 |
| `.ogm` | 6 | 8 |
| `.pdf` | 2 | 6 |
| `.png` | 328 | 4702 |
| `.ps1` | 1 | 0 |
| `.ptb` | 1470 | 1866 |
| `.qst` | 122 | 474 |
| `.rtf` | 0 | 1 |
| `.sfk` | 6 | 0 |
| `.sqlite` | 1 | 0 |
| `.stream` | 183 | 195 |
| `.strg` | 5 | 7 |
| `.sub` | 2 | 3 |
| `.tga` | 40 | 40 |
| `.track` | 124 | 161 |
| `.ttf` | 1 | 0 |
| `.txt` | 81 | 196 |
| `.ui` | 120 | 122 |
| `.vdf` | 0 | 1 |
| `.vmsp` | 0 | 3 |
| `.wav` | 2329 | 4221 |

## Сигнатуры форматов (первые 4 байта) у обычных файлов

Одинаковые сигнатуры у одного расширения в разных играх - формат, скорее всего, тот же. У файлов из архивов сигнатур в манифесте нет.

| Ext | legend | crossworlds |
|---|---|---|
| `.act` | `02000000`x347 | `02000000`x3 |
| `.ani` | - | `52494646`x4 |
| `.atom` | - | `6d61696e`x6 |
| `.bak` | `fffe2f00`x1, `3d3d6865`x1 | - |
| `.bik` | `42494b69`x11 | `42494b69`x17 |
| `.bma` | - | `06000400`x18 |
| `.cab` | - | `4d534346`x154 |
| `.cfg` | `fffe2f00`x1 | - |
| `.chat` | `02000000`x405 | `02000000`x1 |
| `.csv` | `efbbbf22`x2 | - |
| `.dat` | `496e6e6f`x1 | `496e6e6f`x1 |
| `.dds` | - | `44445320`x2 |
| `.dll` | `4d5a9000`x7 | `4d5a9000`x7 |
| `.et` | - | `6e616d65`x2 |
| `.exe` | `4d5a9000`x1, `4d5a5000`x1 | `4d5a9000`x3, `4d5a5000`x1 |
| `.hero` | `02000000`x90 | `02000000`x1 |
| `.htm` | - | `68656c70`x9 |
| `.ico` | `00000100`x1 | - |
| `.ini` | `5b2e5368`x1, `73657473`x1, `23232323`x1 | `73657466`x2, `73657473`x1, `23232323`x1 |
| `.json` | `7b0d0a20`x2 | - |
| `.kfs` | `504b0304`x11 | `504b0304`x13 |
| `.lng` | `fffe6300`x1218, `fffe7100`x319, `fffe2f00`x49 | `fffe6800`x3, `fffe6100`x2, `fffe6900`x2 |
| `.loc` | `02000000`x2067, `06000000`x105 | `02000000`x12, `06000000`x4 |
| `.lu` | `02000000`x254 | `02000000`x9 |
| `.lua` | `66756e63`x22, `0d0a6675`x6, `2d2d202a`x4 | `66756e63`x1 |
| `.mp3` | - | `49443304`x56 |
| `.ogg` | `4f676753`x37 | `4f676753`x48 |
| `.ogm` | `4f676753`x6 | `4f676753`x8 |
| `.pdf` | `25504446`x2 | `25504446`x6 |
| `.png` | `89504e47`x12 | `89504e47`x3194 |
| `.ps1` | `0a706172`x1 | - |
| `.qst` | `02000000`x122 | `02000000`x91 |
| `.rtf` | - | `7b5c7274`x1 |
| `.sqlite` | `53514c69`x1 | - |
| `.stream` | `0df0adde`x183 | `0df0adde`x193 |
| `.strg` | `736c6362`x5 | `736c6362`x1, `02000000`x1 |
| `.ttf` | `00010000`x1 | - |
| `.txt` | `0d0a2f2f`x8, `efbbbfd0`x7, `67616d65`x2 | `636f6e73`x13, `0d0a636f`x8, `0d0a0d0a`x5 |
| `.ui` | `6775695f`x12 | - |
| `.vdf` | - | `22696e73`x1 |

## legend -> crossworlds

Сопоставление по имени файла (папка и архив не учитываются).

- Есть в обеих, содержимое одинаковое: **16868**
- Есть в обеих, содержимое отличается: **1939**
- Нет в legend вообще (кандидаты на перенос): **12774** (4136.7 МБ)

### Новое в crossworlds: где лежит и какого типа (топ 40 по размеру)

| Папка или архив | Ext | Файлов | Размер |
|---|---|---|---|
| `sessions/addon/locations` | `.stream` | 74 | 2526.6 МБ |
| `sessions/champion/locations` | `.stream` | 10 | 302.7 МБ |
| `sessions/orcs/locations` | `.stream` | 8 | 183.7 МБ |
| `Soundtrack` | `.mp3` | 56 | 167.1 МБ |
| `data/interface_textures.kfs` | `.png` | 1226 | 129.5 МБ |
| `data/sounds.kfs` | `.wav` | 1892 | 128.2 МБ |
| `data/animation.kfs` | `.bsa` | 614 | 101.1 МБ |
| `_CommonRedist/DirectX/Jun2010` | `.cab` | 154 | 96.1 МБ |
| `.` | `.pdf` | 3 | 91.6 МБ |
| `sessions/defender/locations` | `.stream` | 4 | 77.2 МБ |
| `manual` | `.pdf` | 3 | 58.9 МБ |
| `data/textures.kfs` | `.dds` | 238 | 53.1 МБ |
| `data/music` | `.ogg` | 12 | 45.1 МБ |
| `sessions/addon/ses.kfs` | `.loc` | 816 | 22.5 МБ |
| `sessions/orcs` | `.kfs` | 1 | 21.1 МБ |
| `data/models.kfs` | `.bma` | 155 | 14.1 МБ |
| `sessions/orcs/orcs.kfs` | `.png` | 82 | 11.8 МБ |
| `data/models.kfs` | `.bms` | 107 | 11.5 МБ |
| `manual/tutorial/locations/sunset_isle` | `.stream` | 1 | 11.2 МБ |
| `sessions/orcs/orcs.kfs` | `.loc` | 175 | 8.2 МБ |
| `data/interface/video` | `.ogm` | 3 | 8.2 МБ |
| `editor/thumbnails` | `.png` | 3064 | 8.0 МБ |
| `sessions/champion` | `.kfs` | 1 | 5.6 МБ |
| `sessions/addon` | `.kfs` | 2 | 5.5 МБ |
| `data/video` | `.ogm` | 2 | 4.2 МБ |
| `data/textures.kfs` | `.png` | 14 | 3.1 МБ |
| `sessions/champion/champion.kfs` | `.loc` | 112 | 2.6 МБ |
| `sessions/champion/champion.kfs` | `.lng` | 122 | 2.3 МБ |
| `.` | `.exe` | 1 | 2.2 МБ |
| `sessions/orcs/orcs.kfs` | `.dds` | 13 | 2.0 МБ |
| `editor/fileset/Hero. Searcher Bill Gillbert/Data/Models` | `.bma` | 9 | 1.9 МБ |
| `sessions/defender` | `.kfs` | 1 | 1.6 МБ |
| `_CommonRedist/DirectX/Jun2010` | `.dll` | 2 | 1.6 МБ |
| `sessions/addon/loc_ses.kfs` | `.lng` | 367 | 1.5 МБ |
| `data/loc_data.kfs` | `.ogg` | 1 | 1.5 МБ |
| `sessions/addon/ses.kfs` | `.chat` | 276 | 1.2 МБ |
| `editor/fileset/Hero. Searcher Bill Gillbert/Data/Interface` | `.png` | 9 | 1.2 МБ |
| `sessions/defender/defender.kfs` | `.loc` | 51 | 1.2 МБ |
| `sessions/champion/champion.kfs` | `.png` | 14 | 1.2 МБ |
| `sessions/orcs/orcs.kfs` | `.bma` | 11 | 1.2 МБ |

### Новые скрипты и данные в crossworlds (топ 40 по размеру)

- `editor/editor_containers.txt` (138422 Б)
- `editor/editor_atoms.txt` (111188 Б)
- `editor/editor_levels.txt` (102571 Б)
- `editor/editor_struids.txt` (84124 Б)
- `sessions/orcs/orcs.kfs!/battle_akademy.lua` (61446 Б)
- `sessions/addon/ses.kfs!/medals.txt` (59540 Б)
- `sessions/orcs/orcs.kfs!/medals.txt` (59540 Б)
- `sessions/defender/defender.kfs!/properties.txt` (57778 Б)
- `sessions/orcs/orcs.kfs!/new_spells.lua` (57027 Б)
- `data/data.kfs!/time_guard.atom` (53396 Б)
- `editor/dialogs/editor_dialogs_embryo.txt` (52754 Б)
- `sessions/champion/champion.kfs!/properties.txt` (50186 Б)
- `editor/dialogs/editor_dialogs_light.txt` (49265 Б)
- `sessions/defender/defender.kfs!/medals.txt` (46810 Б)
- `sessions/orcs/orcs.kfs!/addon_boss.lua` (45245 Б)
- `sessions/addon/ses.kfs!/addon_boss.lua` (44918 Б)
- `editor/editor_labels.txt` (44620 Б)
- `sessions/orcs/orcs.kfs!/addon_special_attacks.lua` (43962 Б)
- `sessions/addon/ses.kfs!/addon_special_attacks.lua` (43839 Б)
- `sessions/champion/champion.kfs!/medals.txt` (41933 Б)
- `editor/dialogs/editor_dialogs_action.txt` (40957 Б)
- `sessions/orcs/orcs.kfs!/other_units.lua` (40919 Б)
- `sessions/orcs/orcs.kfs!/runemage.lua` (36921 Б)
- `sessions/champion/champion.kfs!/driller_boss.atom` (36811 Б)
- `data/data.kfs!/driller_boss.atom` (36809 Б)
- `editor/dialogs/editor_dialogs_objmgr.txt` (36317 Б)
- `editor/dialogs/editor_dialogs_tools.txt` (35946 Б)
- `data/data.kfs!/town_1680x945.ui` (34606 Б)
- `sessions/orcs/orcs.kfs!/companion.txt` (33807 Б)
- `sessions/orcs/orcs.kfs!/addon_pet.lua` (32242 Б)
- `sessions/addon/ses.kfs!/companion.txt` (31722 Б)
- `sessions/defender/defender.kfs!/companion.txt` (31709 Б)
- `data/data.kfs!/pet.atom` (30629 Б)
- `sessions/defender/defender.kfs!/pet.atom` (30623 Б)
- `sessions/addon/ses.kfs!/addon_pet.lua` (29939 Б)
- `data/data.kfs!/start2_1680x1050.ui` (29668 Б)
- `data/data.kfs!/start2_1680x945.ui` (29628 Б)
- `data/data.kfs!/start_1680x945.ui` (29628 Б)
- `data/data.kfs!/start2_1280x1024.ui` (29611 Б)
- `data/data.kfs!/start2.ui` (29603 Б)

### Те же имена, но другое содержимое: скрипты и данные (топ 40 по размеру)

| Файл в crossworlds | Байт | Байт в legend |
|---|---|---|
| `sessions/orcs/orcs.kfs!/items.txt` | 538283 | 292090 |
| `sessions/orcs/orcs.kfs!/embryos.txt` | 472242 | 346271 |
| `sessions/champion/champion.kfs!/embryos.txt` | 465489 | 346271 |
| `sessions/defender/defender.kfs!/embryos.txt` | 463990 | 346271 |
| `sessions/addon/ses.kfs!/embryos.txt` | 463982 | 346271 |
| `sessions/champion/champion.kfs!/items.txt` | 390820 | 292090 |
| `sessions/defender/defender.kfs!/items.txt` | 390418 | 292090 |
| `sessions/addon/ses.kfs!/items.txt` | 390400 | 292090 |
| `data/sounds.kfs!/sounds.csv` | 170405 | 130682 |
| `sessions/orcs/orcs.kfs!/arena.lua` | 161629 | 111953 |
| `sessions/champion/champion.kfs!/arena.lua` | 134476 | 111953 |
| `sessions/defender/defender.kfs!/arena.lua` | 131493 | 111953 |
| `sessions/addon/ses.kfs!/arena.lua` | 130168 | 111953 |
| `sessions/addon/ses.kfs!/spells.lua` | 121217 | 115464 |
| `sessions/addon/ses.kfs!/special_attacks.lua` | 72382 | 72175 |
| `sessions/champion/champion.kfs!/spells.txt` | 63351 | 50573 |
| `data/data.kfs!/death.atom` | 55541 | 55536 |
| `sessions/orcs/orcs.kfs!/spells.txt` | 55163 | 50573 |
| `sessions/addon/ses.kfs!/spells.txt` | 54964 | 50573 |
| `sessions/defender/defender.kfs!/spells.txt` | 54964 | 50573 |
| `data/data.kfs!/hero.ui` | 48845 | 51392 |
| `sessions/addon/ses.kfs!/spells_common.lua` | 47122 | 43535 |
| `data/data.kfs!/therock.atom` | 38548 | 38580 |
| `sessions/addon/ses.kfs!/unit_features.lua` | 37635 | 37803 |
| `sessions/addon/ses.kfs!/spells_hint.lua` | 37205 | 36216 |
| `data/data.kfs!/options.ui` | 37118 | 28757 |
| `sessions/orcs/orcs.kfs!/spells_power.lua` | 35167 | 34171 |
| `sessions/addon/ses.kfs!/spells_power.lua` | 35085 | 34171 |
| `sessions/addon/ses.kfs!/pawn.lua` | 34713 | 33693 |
| `data/data.kfs!/town_1680x1050.ui` | 34611 | 38161 |
| `data/data.kfs!/town_1_1280x1024.ui` | 34364 | 36771 |
| `data/data.kfs!/town_1.ui` | 34152 | 36559 |
| `sessions/orcs/orcs.kfs!/item_fight.lua` | 33154 | 15614 |
| `sessions/champion/champion.kfs!/skills.txt` | 32606 | 21907 |
| `sessions/orcs/orcs.kfs!/skills.txt` | 32237 | 21907 |
| `data/data.kfs!/records.ui` | 32139 | 29228 |
| `data/data.kfs!/slime.atom` | 30482 | 30485 |
| `sessions/addon/ses.kfs!/skills.txt` | 30440 | 21907 |
| `data/data.kfs!/start_1680x1050.ui` | 29668 | 5896 |
| `data/data.kfs!/start_1280x1024.ui` | 29611 | 5448 |
