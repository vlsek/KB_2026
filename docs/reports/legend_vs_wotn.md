# Сравнение игр серии

| Игра | Файлов (с содержимым .kfs) | Размер |
|---|---|---|
| legend | 22962 | 7183.2 МБ |
| wotn | 45031 | 10214.8 МБ |

## Расширения по играм (число файлов)

| Ext | legend | wotn |
|---|---|---|
| `(нет)` | 0 | 1 |
| `.act` | 348 | 919 |
| `.ani` | 48 | 46 |
| `.atom` | 2654 | 4936 |
| `.bak` | 2 | 0 |
| `.bdic` | 0 | 1 |
| `.bft` | 3 | 9 |
| `.bik` | 11 | 0 |
| `.bin` | 0 | 1 |
| `.bma` | 1161 | 1517 |
| `.bmc` | 1 | 1 |
| `.bmp` | 1 | 10 |
| `.bms` | 1789 | 2163 |
| `.bp` | 1 | 0 |
| `.bsa` | 2690 | 4057 |
| `.cfg` | 2 | 7 |
| `.chat` | 406 | 954 |
| `.cms` | 1544 | 1777 |
| `.csh` | 1068 | 1182 |
| `.csv` | 9 | 11 |
| `.dat` | 3 | 3 |
| `.dds` | 2067 | 2746 |
| `.dll` | 7 | 9 |
| `.envlp` | 5 | 5 |
| `.exe` | 2 | 4 |
| `.f` | 1 | 1 |
| `.fmk` | 4 | 4 |
| `.fnt` | 4 | 4 |
| `.gpk` | 1 | 0 |
| `.hashdb` | 0 | 4 |
| `.hero` | 90 | 250 |
| `.hfs` | 0 | 1 |
| `.ico` | 1 | 4 |
| `.info` | 0 | 2 |
| `.ini` | 4 | 6 |
| `.jpg` | 0 | 9 |
| `.json` | 2 | 1 |
| `.kfs` | 11 | 19 |
| `.lng` | 1625 | 1888 |
| `.lnk` | 0 | 1 |
| `.loc` | 2172 | 5488 |
| `.lu` | 254 | 755 |
| `.lua` | 97 | 120 |
| `.max` | 0 | 1 |
| `.mod` | 1 | 0 |
| `.msg` | 0 | 2 |
| `.msk` | 11 | 6 |
| `.ogg` | 41 | 64 |
| `.ogm` | 6 | 14 |
| `.pak` | 0 | 1 |
| `.pdf` | 2 | 1 |
| `.png` | 328 | 2646 |
| `.ps1` | 1 | 0 |
| `.pt` | 0 | 2525 |
| `.ptb` | 1470 | 2214 |
| `.qst` | 122 | 301 |
| `.script` | 0 | 1 |
| `.sfk` | 6 | 0 |
| `.sqlite` | 1 | 0 |
| `.stream` | 183 | 251 |
| `.strg` | 5 | 181 |
| `.sub` | 2 | 4 |
| `.tga` | 40 | 41 |
| `.tif` | 0 | 1 |
| `.track` | 124 | 187 |
| `.ttf` | 1 | 3 |
| `.txt` | 81 | 108 |
| `.ui` | 120 | 205 |
| `.vmpd` | 0 | 71 |
| `.vmsp` | 0 | 2698 |
| `.vmxt` | 0 | 17 |
| `.wav` | 2329 | 4570 |
| `.xls` | 0 | 1 |
| `.zip` | 0 | 1 |

## Сигнатуры форматов (первые 4 байта) у обычных файлов

Одинаковые сигнатуры у одного расширения в разных играх - формат, скорее всего, тот же. У файлов из архивов сигнатур в манифесте нет.

| Ext | legend | wotn |
|---|---|---|
| `.act` | `02000000`x347 | - |
| `.bak` | `fffe2f00`x1, `3d3d6865`x1 | - |
| `.bdic` | - | `42446963`x1 |
| `.bik` | `42494b69`x11 | - |
| `.cfg` | `fffe2f00`x1 | - |
| `.chat` | `02000000`x405 | - |
| `.csv` | `efbbbf22`x2 | - |
| `.dat` | `496e6e6f`x1 | `496e6e6f`x2 |
| `.dll` | `4d5a9000`x7 | `4d5a9000`x9 |
| `.exe` | `4d5a9000`x1, `4d5a5000`x1 | `4d5a5000`x3, `4d5a9000`x1 |
| `.hashdb` | - | `504b0304`x2 |
| `.hero` | `02000000`x90 | - |
| `.hfs` | - | `504b0304`x1 |
| `.ico` | `00000100`x1 | `00000100`x4 |
| `.info` | - | `7b0a2020`x2 |
| `.ini` | `5b2e5368`x1, `73657473`x1, `23232323`x1 | `5b496e73`x2, `efbbbf5b`x1, `73657473`x1 |
| `.json` | `7b0d0a20`x2 | - |
| `.kfs` | `504b0304`x11 | `504b0304`x19 |
| `.lng` | `fffe6300`x1218, `fffe7100`x319, `fffe2f00`x49 | - |
| `.lnk` | - | `4c000000`x1 |
| `.loc` | `02000000`x2067, `06000000`x105 | `02000000`x4036, `06000000`x1452 |
| `.lu` | `02000000`x254 | - |
| `.lua` | `66756e63`x22, `0d0a6675`x6, `2d2d202a`x4 | - |
| `.msg` | - | `496e6e6f`x2 |
| `.ogg` | `4f676753`x37 | `4f676753`x56 |
| `.ogm` | `4f676753`x6 | `4f676753`x14 |
| `.pak` | - | `01000000`x1 |
| `.pdf` | `25504446`x2 | `25504446`x1 |
| `.png` | `89504e47`x12 | - |
| `.ps1` | `0a706172`x1 | - |
| `.qst` | `02000000`x122 | - |
| `.script` | - | `7b0a2020`x1 |
| `.sqlite` | `53514c69`x1 | - |
| `.stream` | `0df0adde`x183 | `0df0adde`x251 |
| `.strg` | `736c6362`x5 | - |
| `.tif` | - | `49492a00`x1 |
| `.ttf` | `00010000`x1 | - |
| `.txt` | `0d0a2f2f`x8, `efbbbfd0`x7, `67616d65`x2 | `0d0a0d0a`x1 |
| `.ui` | `6775695f`x12 | - |
| `.zip` | - | `504b0304`x1 |

## legend -> wotn

Сопоставление по имени файла (папка и архив не учитываются).

- Есть в обеих, содержимое одинаковое: **16502**
- Есть в обеих, содержимое отличается: **3518**
- Нет в legend вообще (кандидаты на перенос): **24921** (6341.8 МБ)

### Новое в wotn: где лежит и какого типа (топ 40 по размеру)

| Папка или архив | Ext | Файлов | Размер |
|---|---|---|---|
| `sessions/addon/locations` | `.stream` | 141 | 4486.6 МБ |
| `sessions/ice_and_fire/locations` | `.stream` | 16 | 404.4 МБ |
| `data/textures.kfs` | `.dds` | 640 | 233.6 МБ |
| `data/interface_textures.kfs` | `.png` | 1975 | 191.8 МБ |
| `data/animation.kfs` | `.bsa` | 1367 | 179.2 МБ |
| `data/sounds.kfs` | `.wav` | 2234 | 170.8 МБ |
| `data/music` | `.ogg` | 30 | 95.1 МБ |
| `.` | `.tif` | 1 | 77.3 МБ |
| `sessions/ice_and_fire/locations` | `.loc` | 1733 | 56.4 МБ |
| `sessions/ice_and_fire` | `.kfs` | 1 | 55.7 МБ |
| `sessions/addon/locations` | `.loc` | 1548 | 50.8 МБ |
| `data/interface_textures.kfs` | `.bmp` | 10 | 48.9 МБ |
| `.` | `.dll` | 6 | 41.8 МБ |
| `sessions/ice_and_fire/ses.kfs` | `.png` | 428 | 36.2 МБ |
| `data/models.kfs` | `.bma` | 325 | 32.9 МБ |
| `data/models.kfs` | `.bms` | 362 | 26.0 МБ |
| `.` | `.exe` | 2 | 17.5 МБ |
| `.` | `.pdf` | 1 | 15.9 МБ |
| `data` | `.kfs` | 4 | 14.3 МБ |
| `data/interface/video` | `.ogm` | 12 | 10.9 МБ |
| `data/animation.kfs` | `.max` | 1 | 9.5 МБ |
| `sessions/ice_and_fire/ses.kfs` | `.dds` | 39 | 6.7 МБ |
| `data/textures.kfs` | `.png` | 25 | 6.4 МБ |
| `data/data.kfs` | `.pt` | 2525 | 5.7 МБ |
| `data/sky.kfs` | `.dds` | 12 | 5.3 МБ |
| `data/data.kfs` | `.vmsp` | 2698 | 4.6 МБ |
| `data/patch_001.kfs` | `.png` | 4 | 3.6 МБ |
| `sessions/ice_and_fire/localization/rus_loc_ses_iaf.kfs` | `.lng` | 703 | 3.3 МБ |
| `.` | `.dat` | 1 | 3.2 МБ |
| `sessions/addon` | `.kfs` | 2 | 3.1 МБ |
| `data/sounds.kfs` | `.ogg` | 2 | 3.0 МБ |
| `goggame-1207667153.hashdb` | `.hashdb` | 1 | 2.9 МБ |
| `sessions/ice_and_fire/ses.kfs` | `.bma` | 33 | 2.7 МБ |
| `data/patch_003.kfs` | `.cfg` | 6 | 2.6 МБ |
| `sessions/ice_and_fire/ses.kfs` | `.chat` | 523 | 2.5 МБ |
| `sessions/addon/loc_ses.kfs` | `.lng` | 569 | 2.4 МБ |
| `sessions/ice_and_fire/localization` | `.kfs` | 4 | 2.2 МБ |
| `sessions/addon/ses.kfs` | `.chat` | 431 | 2.1 МБ |
| `sessions/ice_and_fire/ses.kfs` | `.atom` | 926 | 1.9 МБ |
| `data/data.kfs` | `.jpg` | 6 | 1.5 МБ |

### Новые скрипты и данные в wotn (топ 40 по размеру)

- `data/patch_003.kfs!/sound_info.cfg` (2589744 Б)
- `sessions/ice_and_fire/ses.kfs!/unit_special_attacks.lua` (399631 Б)
- `sessions/ice_and_fire/ses.kfs!/medals.txt` (355414 Б)
- `sessions/addon/ses.kfs!/unit_special_attacks.lua` (259705 Б)
- `sessions/ice_and_fire/ses.kfs!/dlc_if_items_2.txt` (182108 Б)
- `sessions/ice_and_fire/ses.kfs!/addon_arena.lua` (156193 Б)
- `sessions/addon/ses.kfs!/addon_arena.lua` (137405 Б)
- `sessions/ice_and_fire/ses.kfs!/addon_pet.lua` (112603 Б)
- `sessions/addon/ses.kfs!/addon_pet.lua` (111964 Б)
- `sessions/ice_and_fire/ses.kfs!/unit_features_master.lua` (110524 Б)
- `data/patch_003.kfs!/sound_arrays.cfg` (104332 Б)
- `sessions/ice_and_fire/ses.kfs!/133973322.chat` (100890 Б)
- `sessions/addon/ses.kfs!/133973322.chat` (100888 Б)
- `sessions/ice_and_fire/ses.kfs!/dlc_if_items_1.txt` (96030 Б)
- `sessions/addon/ses.kfs!/medals.txt` (86378 Б)
- `sessions/ice_and_fire/ses.kfs!/subturns.lua` (75102 Б)
- `sessions/addon/ses.kfs!/unit_features_master.lua` (59802 Б)
- `sessions/addon/ses.kfs!/938639259.chat` (59032 Б)
- `sessions/ice_and_fire/ses.kfs!/938639259.chat` (59032 Б)
- `EULA.txt` (56956 Б)
- `sessions/ice_and_fire/ses.kfs!/exp_system.lua` (55506 Б)
- `sessions/addon/ses.kfs!/subturns.lua` (54641 Б)
- `data/data.kfs!/time_guard.atom` (53396 Б)
- `sessions/ice_and_fire/ses.kfs!/hidden.txt` (42822 Б)
- `sessions/addon/ses.kfs!/1197657544.chat` (39621 Б)
- `sessions/ice_and_fire/ses.kfs!/1197657544.chat` (39621 Б)
- `sessions/addon/ses.kfs!/1474540606.chat` (39279 Б)
- `sessions/ice_and_fire/ses.kfs!/1474540606.chat` (38293 Б)
- `sessions/addon/ses.kfs!/driller_boss.atom` (37921 Б)
- `sessions/ice_and_fire/ses.kfs!/driller_boss.atom` (37921 Б)
- `sessions/ice_and_fire/ses.kfs!/addon_boss.lua` (37900 Б)
- `data/declarations.kfs!/town_1680x945.ui` (37325 Б)
- `data/data.kfs!/driller_boss.atom` (37046 Б)
- `sessions/addon/ses.kfs!/addon_boss.lua` (34098 Б)
- `sessions/addon/ses.kfs!/644254083.chat` (32573 Б)
- `sessions/ice_and_fire/ses.kfs!/valkyres.txt` (32564 Б)
- `sessions/ice_and_fire/ses.kfs!/white_hawk.atom` (32558 Б)
- `sessions/ice_and_fire/ses.kfs!/644254083.chat` (31303 Б)
- `sessions/addon/ses.kfs!/rune_knowledge.lua` (30196 Б)
- `sessions/ice_and_fire/ses.kfs!/55166676.chat` (28528 Б)

### Те же имена, но другое содержимое: скрипты и данные (топ 40 по размеру)

| Файл в wotn | Байт | Байт в legend |
|---|---|---|
| `sessions/ice_and_fire/ses.kfs!/items.txt` | 1390618 | 292090 |
| `sessions/ice_and_fire/ses.kfs!/embryos.txt` | 1023088 | 346271 |
| `sessions/addon/ses.kfs!/items.txt` | 638212 | 292090 |
| `sessions/addon/ses.kfs!/embryos.txt` | 481287 | 346271 |
| `sessions/ice_and_fire/ses.kfs!/arena.lua` | 330217 | 111953 |
| `sessions/addon/ses.kfs!/arena.lua` | 273267 | 111953 |
| `sessions/ice_and_fire/ses.kfs!/spells.lua` | 250813 | 115464 |
| `sessions/addon/ses.kfs!/spells.lua` | 249407 | 115464 |
| `data/patch_003.kfs!/sounds.csv` | 193521 | 130682 |
| `sessions/ice_and_fire/ses.kfs!/sounds.csv` | 193521 | 130682 |
| `data/patch_001.kfs!/sounds.csv` | 193220 | 130682 |
| `data/sounds.kfs!/sounds.csv` | 192991 | 130682 |
| `sessions/ice_and_fire/ses.kfs!/spells.txt` | 156926 | 50573 |
| `sessions/addon/ses.kfs!/boss.lua` | 109485 | 24332 |
| `sessions/ice_and_fire/ses.kfs!/boss.lua` | 109485 | 24332 |
| `sessions/ice_and_fire/ses.kfs!/spells_power.lua` | 81093 | 34171 |
| `sessions/addon/ses.kfs!/spells_power.lua` | 79626 | 34171 |
| `sessions/addon/ses.kfs!/spells.txt` | 77658 | 50573 |
| `sessions/ice_and_fire/ses.kfs!/spells_common.lua` | 67504 | 43535 |
| `sessions/addon/ses.kfs!/spells_hint.lua` | 61263 | 36216 |
| `sessions/ice_and_fire/ses.kfs!/spells_hint.lua` | 61263 | 36216 |
| `sessions/ice_and_fire/ses.kfs!/special_hint.lua` | 58822 | 6951 |
| `sessions/ice_and_fire/ses.kfs!/spell_effects.lua` | 56724 | 20685 |
| `sessions/addon/ses.kfs!/spells_common.lua` | 55825 | 43535 |
| `data/data.kfs!/death.atom` | 55541 | 55536 |
| `data/declarations.kfs!/hero.ui` | 52034 | 51392 |
| `sessions/addon/ses.kfs!/spell_effects.lua` | 51376 | 20685 |
| `data/declarations.kfs!/cam_tracks.txt` | 43596 | 35835 |
| `sessions/ice_and_fire/ses.kfs!/pawn.lua` | 40910 | 33693 |
| `sessions/addon/ses.kfs!/pawn.lua` | 40516 | 33693 |
| `data/data.kfs!/therock.atom` | 38548 | 38580 |
| `data/declarations.kfs!/options.ui` | 38060 | 28757 |
| `sessions/ice_and_fire/ses.kfs!/combat_log.lua` | 36531 | 11565 |
| `sessions/ice_and_fire/ses.kfs!/items_monster.txt` | 36170 | 13690 |
| `data/declarations.kfs!/town_1680x1050.ui` | 35505 | 38161 |
| `data/declarations.kfs!/town_1_1280x1024.ui` | 35255 | 36771 |
| `data/declarations.kfs!/town_1.ui` | 35043 | 36559 |
| `sessions/ice_and_fire/ses.kfs!/specials.txt` | 34762 | 11342 |
| `data/declarations.kfs!/records.ui` | 33690 | 29228 |
| `data/data.kfs!/slime.atom` | 30482 | 30485 |
