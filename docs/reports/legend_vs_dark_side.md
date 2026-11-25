# Сравнение игр серии

| Игра | Файлов (с содержимым .kfs) | Размер |
|---|---|---|
| legend | 22962 | 7183.2 МБ |
| dark_side | 44101 | 9207.6 МБ |

## Расширения по играм (число файлов)

| Ext | legend | dark_side |
|---|---|---|
| `(нет)` | 0 | 1 |
| `.act` | 348 | 322 |
| `.ani` | 48 | 46 |
| `.atom` | 2654 | 4552 |
| `.bak` | 2 | 1 |
| `.bft` | 3 | 9 |
| `.bik` | 11 | 0 |
| `.bin` | 0 | 1 |
| `.bma` | 1161 | 1612 |
| `.bmc` | 1 | 0 |
| `.bmp` | 1 | 0 |
| `.bms` | 1789 | 2378 |
| `.bp` | 1 | 0 |
| `.bsa` | 2690 | 4436 |
| `.cfg` | 2 | 9 |
| `.chat` | 406 | 867 |
| `.cmd` | 0 | 1 |
| `.cms` | 1544 | 1814 |
| `.csh` | 1068 | 1218 |
| `.csv` | 9 | 7 |
| `.dat` | 3 | 3 |
| `.dds` | 2067 | 3115 |
| `.dll` | 7 | 4 |
| `.envlp` | 5 | 5 |
| `.exe` | 2 | 8 |
| `.f` | 1 | 1 |
| `.fmk` | 4 | 5 |
| `.fnt` | 4 | 5 |
| `.gpk` | 1 | 0 |
| `.hashdb` | 0 | 4 |
| `.hero` | 90 | 136 |
| `.hfs` | 0 | 1 |
| `.ico` | 1 | 4 |
| `.info` | 0 | 2 |
| `.ini` | 4 | 7 |
| `.jpg` | 0 | 9 |
| `.json` | 2 | 1 |
| `.kfs` | 11 | 17 |
| `.lng` | 1625 | 4275 |
| `.lnk` | 0 | 1 |
| `.loc` | 2172 | 2198 |
| `.lu` | 254 | 445 |
| `.lua` | 97 | 61 |
| `.max` | 0 | 1 |
| `.mod` | 1 | 0 |
| `.msg` | 0 | 2 |
| `.msk` | 11 | 4 |
| `.ogg` | 41 | 65 |
| `.ogm` | 6 | 15 |
| `.pdf` | 2 | 1 |
| `.png` | 328 | 2558 |
| `.ps1` | 1 | 0 |
| `.pt` | 0 | 2821 |
| `.ptb` | 1470 | 2468 |
| `.ptm` | 0 | 1 |
| `.qst` | 122 | 200 |
| `.script` | 0 | 2 |
| `.sfk` | 6 | 0 |
| `.sqlite` | 1 | 0 |
| `.stream` | 183 | 200 |
| `.strg` | 5 | 94 |
| `.sub` | 2 | 2 |
| `.tga` | 40 | 41 |
| `.track` | 124 | 187 |
| `.ttf` | 1 | 3 |
| `.txt` | 81 | 60 |
| `.ui` | 120 | 181 |
| `.vmpd` | 0 | 71 |
| `.vmsp` | 0 | 2819 |
| `.vmxt` | 0 | 17 |
| `.wav` | 2329 | 4705 |
| `.xls` | 0 | 1 |
| `.zip` | 0 | 1 |

## Сигнатуры форматов (первые 4 байта) у обычных файлов

Одинаковые сигнатуры у одного расширения в разных играх - формат, скорее всего, тот же. У файлов из архивов сигнатур в манифесте нет.

| Ext | legend | dark_side |
|---|---|---|
| `.act` | `02000000`x347 | - |
| `.bak` | `fffe2f00`x1, `3d3d6865`x1 | `4d5a9000`x1 |
| `.bik` | `42494b69`x11 | - |
| `.cfg` | `fffe2f00`x1 | `fffe7b00`x7, `7b000d00`x1 |
| `.chat` | `02000000`x405 | - |
| `.cmd` | - | `40656368`x1 |
| `.csv` | `efbbbf22`x2 | `40484541`x6 |
| `.dat` | `496e6e6f`x1 | `496e6e6f`x2 |
| `.dll` | `4d5a9000`x7 | `4d5a9000`x4 |
| `.exe` | `4d5a9000`x1, `4d5a5000`x1 | `4d5a9000`x6, `4d5a5000`x2 |
| `.hashdb` | - | `504b0304`x2 |
| `.hero` | `02000000`x90 | - |
| `.hfs` | - | `504b0304`x1 |
| `.ico` | `00000100`x1 | `00000100`x4 |
| `.info` | - | `7b0d0a20`x2 |
| `.ini` | `5b2e5368`x1, `73657473`x1, `23232323`x1 | `5b496e73`x2, `efbbbf5b`x1, `efbbbf0d`x1 |
| `.json` | `7b0d0a20`x2 | - |
| `.kfs` | `504b0304`x11 | `504b0304`x17 |
| `.lng` | `fffe6300`x1218, `fffe7100`x319, `fffe2f00`x49 | - |
| `.lnk` | - | `4c000000`x1 |
| `.loc` | `02000000`x2067, `06000000`x105 | `02000000`x1601, `06000000`x597 |
| `.lu` | `02000000`x254 | - |
| `.lua` | `66756e63`x22, `0d0a6675`x6, `2d2d202a`x4 | - |
| `.msg` | - | `496e6e6f`x2 |
| `.ogg` | `4f676753`x37 | `4f676753`x65 |
| `.ogm` | `4f676753`x6 | `4f676753`x15 |
| `.pdf` | `25504446`x2 | `25504446`x1 |
| `.png` | `89504e47`x12 | `89504e47`x1 |
| `.ps1` | `0a706172`x1 | - |
| `.qst` | `02000000`x122 | - |
| `.script` | - | `7b0d0a20`x2 |
| `.sqlite` | `53514c69`x1 | - |
| `.stream` | `0df0adde`x183 | `0df0adde`x200 |
| `.strg` | `736c6362`x5 | - |
| `.ttf` | `00010000`x1 | - |
| `.txt` | `0d0a2f2f`x8, `efbbbfd0`x7, `67616d65`x2 | `0d0a0d0a`x1, `fffe2f00`x1, `40484541`x1 |
| `.ui` | `6775695f`x12 | - |
| `.wav` | - | `52494646`x4705 |
| `.zip` | - | `504b0304`x1 |

## legend -> dark_side

Сопоставление по имени файла (папка и архив не учитываются).

- Есть в обеих, содержимое одинаковое: **15963**
- Есть в обеих, содержимое отличается: **2603**
- Нет в legend вообще (кандидаты на перенос): **25524** (6581.0 МБ)

### Новое в dark_side: где лежит и какого типа (топ 40 по размеру)

| Папка или архив | Ext | Файлов | Размер |
|---|---|---|---|
| `sessions/darkside/locations/dragondor` | `.stream` | 2 | 325.3 МБ |
| `sessions/darkside/locations/m_flying` | `.stream` | 1 | 279.8 МБ |
| `data/textures.kfs` | `.dds` | 648 | 234.5 МБ |
| `data/animation.kfs` | `.bsa` | 1744 | 218.5 МБ |
| `data/interface_textures.kfs` | `.png` | 2178 | 216.5 МБ |
| `data/textures_game.kfs` | `.dds` | 400 | 178.3 МБ |
| `sessions/darkside/locations/aralan` | `.stream` | 1 | 157.4 МБ |
| `sessions/darkside/locations/m_bear_mountain` | `.stream` | 1 | 137.1 МБ |
| `sessions/darkside/locations/m_helvedia` | `.stream` | 1 | 137.1 МБ |
| `sessions/darkside/locations/m_amasonia` | `.stream` | 1 | 134.3 МБ |
| `sessions/darkside/locations/m_inselburg` | `.stream` | 1 | 117.5 МБ |
| `sessions/darkside/locations/m_monteville_dungeon` | `.stream` | 1 | 117.5 МБ |
| `sessions/darkside/locations/m_barazgund` | `.stream` | 1 | 109.1 МБ |
| `sessions/darkside/locations/m_galenirimm` | `.stream` | 1 | 109.1 МБ |
| `sessions/darkside/locations/m_monteville` | `.stream` | 1 | 109.1 МБ |
| `data/music` | `.ogg` | 37 | 107.4 МБ |
| `sessions/darkside/locations/m_whitehill` | `.stream` | 1 | 100.8 МБ |
| `sessions/darkside/locations/m_sandy` | `.stream` | 1 | 100.1 МБ |
| `data` | `.kfs` | 5 | 76.0 МБ |
| `sessions/darkside/locations/arena/a_okkarland02` | `.stream` | 1 | 70.0 МБ |
| `sessions/darkside/locations/arena/a_okkarland_07` | `.stream` | 1 | 70.0 МБ |
| `sessions/darkside/locations/m_okkarland` | `.stream` | 1 | 70.0 МБ |
| `sessions/darkside/locations/m_portland` | `.stream` | 1 | 67.2 МБ |
| `sessions/darkside/locations/m_portland_dark` | `.stream` | 1 | 67.2 МБ |
| `data/sounds/addon/unsorted` | `.wav` | 492 | 65.6 МБ |
| `sessions/darkside/locations/m_catacombs` | `.stream` | 1 | 63.0 МБ |
| `sessions/darkside/locations/m_atrixus` | `.stream` | 1 | 56.7 МБ |
| `sessions/darkside/locations/m_atrixus_late` | `.stream` | 1 | 56.7 МБ |
| `sessions/darkside/locations/d_tristrem_cave` | `.stream` | 1 | 50.4 МБ |
| `sessions/darkside/locations/m_tristrem_late` | `.stream` | 1 | 50.4 МБ |
| `sessions/darkside/locations/m_tristrem_start` | `.stream` | 1 | 50.4 МБ |
| `sessions/darkside/locations/m_zcom` | `.stream` | 1 | 50.4 МБ |
| `sessions/darkside/locations/m_zcom_start` | `.stream` | 1 | 50.4 МБ |
| `sessions/darkside/locations/d_aralan_castle` | `.stream` | 1 | 49.0 МБ |
| `sessions/darkside/locations/d_castle_of_galenerim` | `.stream` | 1 | 49.0 МБ |
| `data/models.kfs` | `.bma` | 453 | 48.3 МБ |
| `data/sounds/darkside` | `.wav` | 137 | 45.7 МБ |
| `sessions/darkside/locations/flat` | `.stream` | 1 | 44.8 МБ |
| `sessions/darkside/locations/m_castle_of_monteville` | `.stream` | 1 | 44.8 МБ |
| `sessions/darkside/locations/m_vampire_start` | `.stream` | 1 | 44.8 МБ |

### Новые скрипты и данные в dark_side (топ 40 по размеру)

- `data/declarations/sound_info.cfg` (2717122 Б)
- `sessions/darkside/ses.kfs!/unit_special_attacks.lua` (303752 Б)
- `sessions/darkside/ses.kfs!/addon_pet.lua` (186785 Б)
- `sessions/darkside/ses.kfs!/medals.txt` (185616 Б)
- `sessions/darkside/ses.kfs!/addon_arena.lua` (140861 Б)
- `data/declarations/sound_arrays.cfg` (104332 Б)
- `sessions/darkside/ses.kfs!/unit_features_master.lua` (83265 Б)
- `sessions/darkside/ses.kfs!/1463634888.chat` (63395 Б)
- `data/data.kfs!/time_guard.atom` (53396 Б)
- `sessions/darkside/ses.kfs!/1747761005.chat` (51780 Б)
- `sessions/darkside/ses.kfs!/1853521803.chat` (48061 Б)
- `sessions/darkside/ses.kfs!/718342330.chat` (45841 Б)
- `sessions/darkside/ses.kfs!/468997640.chat` (45316 Б)
- `sessions/darkside/ses.kfs!/subturns.lua` (44765 Б)
- `EULA.txt` (43728 Б)
- `sessions/darkside/ses.kfs!/hidden.txt` (41828 Б)
- `sessions/darkside/ses.kfs!/1986444880.chat` (39545 Б)
- `data/declarations.kfs!/town_1680x945.ui` (38897 Б)
- `data/data.kfs!/driller_boss.atom` (37921 Б)
- `sessions/darkside/ses.kfs!/190704099.chat` (37792 Б)
- `sessions/darkside/ses.kfs!/1474096100.chat` (37465 Б)
- `sessions/darkside/ses.kfs!/1741255476.chat` (35994 Б)
- `sessions/darkside/ses.kfs!/369239376.chat` (35757 Б)
- `sessions/darkside/ses.kfs!/127158920.chat` (35755 Б)
- `sessions/darkside/ses.kfs!/1637004586.chat` (35512 Б)
- `sessions/darkside/ses.kfs!/dragon_rider.atom` (34660 Б)
- `sessions/darkside/ses.kfs!/addon_boss.lua` (34098 Б)
- `sessions/darkside/ses.kfs!/676658761.chat` (33297 Б)
- `sessions/darkside/ses.kfs!/1362997390.chat` (32697 Б)
- `sessions/darkside/ses.kfs!/1964151822.chat` (31485 Б)
- `sessions/darkside/ses.kfs!/rune_knowledge.lua` (30196 Б)
- `sessions/darkside/ses.kfs!/667766720.chat` (30006 Б)
- `sessions/darkside/ses.kfs!/1234090222.chat` (29200 Б)
- `sessions/darkside/ses.kfs!/54940392.chat` (29197 Б)
- `sessions/darkside/ses.kfs!/1640427661.chat` (28566 Б)
- `sessions/darkside/ses.kfs!/1285257528.chat` (27929 Б)
- `data/declarations.kfs!/victory_many_hero.ui` (27771 Б)
- `sessions/darkside/ses.kfs!/visa.lua` (27412 Б)
- `sessions/darkside/ses.kfs!/831904520.chat` (27175 Б)
- `data/data.kfs!/diablo_boss.atom` (26944 Б)

### Те же имена, но другое содержимое: скрипты и данные (топ 40 по размеру)

| Файл в dark_side | Байт | Байт в legend |
|---|---|---|
| `sessions/darkside/ses.kfs!/items.txt` | 1831136 | 292090 |
| `sessions/darkside/ses.kfs!/embryos.txt` | 1076832 | 346271 |
| `sessions/darkside/ses.kfs!/spells.lua` | 288029 | 115464 |
| `sessions/darkside/ses.kfs!/arena.lua` | 273004 | 111953 |
| `data/sounds/sounds.csv` | 196096 | 130682 |
| `sessions/darkside/ses.kfs!/spells.txt` | 181550 | 50573 |
| `sessions/darkside/ses.kfs!/boss.lua` | 140741 | 24332 |
| `sessions/darkside/ses.kfs!/spells_power.lua` | 93457 | 34171 |
| `sessions/darkside/ses.kfs!/achievements.txt` | 68926 | 993 |
| `sessions/darkside/ses.kfs!/spells_hint.lua` | 68432 | 36216 |
| `sessions/darkside/ses.kfs!/spells_common.lua` | 64624 | 43535 |
| `sessions/darkside/ses.kfs!/skills.txt` | 61526 | 21907 |
| `data/data.kfs!/death.atom` | 55541 | 55536 |
| `data/declarations.kfs!/hero.ui` | 53549 | 51392 |
| `sessions/darkside/ses.kfs!/spell_effects.lua` | 50841 | 20685 |
| `data/declarations.kfs!/cam_tracks.txt` | 43596 | 35835 |
| `sessions/darkside/ses.kfs!/items_monster.txt` | 42334 | 13690 |
| `sessions/darkside/ses.kfs!/pawn.lua` | 40648 | 33693 |
| `data/data.kfs!/therock.atom` | 38548 | 38580 |
| `data/declarations.kfs!/options.ui` | 38060 | 28757 |
| `sessions/darkside/ses.kfs!/special_hint.lua` | 37798 | 6951 |
| `data/declarations.kfs!/town_1680x1050.ui` | 37079 | 38161 |
| `data/declarations.kfs!/town_1_1280x1024.ui` | 36826 | 36771 |
| `sessions/darkside/ses.kfs!/specials.txt` | 36706 | 11342 |
| `data/declarations.kfs!/town_1.ui` | 36612 | 36559 |
| `sessions/darkside/ses.kfs!/item_fight.lua` | 34200 | 15614 |
| `data/declarations.kfs!/records.ui` | 33690 | 29228 |
| `sessions/darkside/ses.kfs!/effects.txt` | 32932 | 9875 |
| `data/data.kfs!/slime.atom` | 30482 | 30485 |
| `sessions/darkside/ses.kfs!/skills.lua` | 29527 | 14908 |
| `sessions/darkside/ses.kfs!/config.txt` | 28392 | 20871 |
| `sessions/darkside/ses.kfs!/spirit_lina.lua` | 27647 | 26397 |
| `sessions/darkside/ses.kfs!/combat_log.lua` | 27076 | 11565 |
| `sessions/darkside/ses.kfs!/spirit_slime.lua` | 25897 | 25962 |
| `data/data.kfs!/lina.atom` | 24651 | 24651 |
| `data/declarations.kfs!/victory_many.ui` | 24615 | 23878 |
| `sessions/darkside/ses.kfs!/logic_hero.lua` | 24492 | 19214 |
| `data/declarations.kfs!/lose_many.ui` | 24420 | 23683 |
| `data/declarations.kfs!/map_1280x1024.ui` | 24303 | 21051 |
| `data/declarations.kfs!/map_1680x1050.ui` | 24114 | 20859 |
