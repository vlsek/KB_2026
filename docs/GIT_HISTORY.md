# История изменений из git (генерируется)

Автоматически собрано `tools/gen_git_history.py` из `git log`. Руками не править. Человеческий ченджлог - `CHANGELOG.md` (обязателен для каждого агента).

## 2026-11-27
**Агент 2**
- `53d2640` mods: medals-panel (панель наград справа от окна героя, 32:9); OWNER_TODO T-22/Q-11; журнал

**Claude (координатор)**
- `170f9d2` docs: проект медалей (MEDALS_DESIGN), план возврата KBMaster, итоги утреннего прогона, OWNER_TODO T-21/Q-10, ROADMAP этап 9, журнал
- `5eff3b4` docs: OWNER_TODO T-20/Q-09, ROADMAP этап 8, журнал (повтор: прошлый коммит не включил эти правки)
- `85f7398` docs: официальное обновление Legend 2026 (достижения), обзор модов других игр, OWNER_TODO T-20/Q-09, ROADMAP этап 8, журнал

**Агент 5**
- `8e08165` mods: lua-api-dump (выгрузка списка Lua API); tools: Run-KBMorning ставит его и собирает файл; журнал, OWNER_TODO
- `7ec2ade` Agent 1 (Claude, залито агентом 5): HANDOFF, slot_dump/slot_test1, журнал; находки: тип слота mslot подтверждён владельцем
- `18b2430` tools: Run-KBMorning.ps1 (один скрипт на все задачи владельца -> один zip); mods: medal-slots-test v2 (propbits=quest); OWNER_TODO T-19, журнал
- `80834dd` Agent 1 (Claude, залито агентом 5): LEGEND_MEDALS_FINDINGS, mods/ach-lua (Lua-выдача медали), журнал

## 2026-11-25
**Агент 4**
- `a4c0bf6` mods: gfx-preset; docs: поиск по ses для #12, журнал; OWNER_TODO T-18, Q-08
- `412c0b0` mods: lua-probe (проверка Lua API Legend); docs: kb.exe без медалей, журнал

**Агент 3**
- `ac8f9f4` docs: Злобоглаз и фамильяр - варианты реализации; tools: Get-KBOwnerPack собирает моды Master и скрипты фамильяра; OWNER_TODO: Q
- `e0fd610` docs: сводная таблица достижений серии с рекомендациями (ACHIEVEMENTS_MASTER); tools: Get-KBOwnerPack собирает локализацию медалей; журнал
- `74aeb4b` tools: Get-KBOwnerPack.ps1 (T-01/T-11/T-12 одним запуском); mods: medal-slots-test - проверка hero.txt до изменений; docs: роль агента 3, T-14, журнал

**Claude (координатор)**
- `344b030` docs+tools: апскейл текстур (опись, конвейер), список достижений Legend с порогами, OWNER_TODO T-14/T-15/Q-06/Q-07, ROADMAP этап 7, журнал
- `c440860` agent1 (залито Claude): mods/stats-panel, docs/FORUM_STATS.md, tools/extract_png.ps1, OWNER_TODO T-12/T-13/Q-05, журнал
- `4b5c7ff` tools: kb_split, kb_extract; docs: SERIES_FINDINGS, reports/, CROSS_GAME 4-5, OWNER_TODO T-11, журнал
- `d6df00d` tools: kb_manifest/kb_compare/kb_grep - сравнение игр по содержимому .kfs; docs: CROSS_GAME, журнал
- `46ed204` achievements-ui: extract_assets.ps1 - ошибки доступа, вывод на рабочий стол, только нужные картинки
- `5b62603` scripts: все .ps1 только ASCII; правило для агентов в AGENTS.md
- `89d7b8c` achievements-ui: пробный интерфейс достижений под 32:9 (генератор, скрипт картинок, README)
- `55f1de0` docs: интерфейс достижений WotN/DS, статистика records, пороги из Steam
- `d7dc2f0` docs: поля интерфейса CW/RS (питомец, награды, баффы) для виджетов и достижений
- `54042c9` ui: журнал заданий по центру 32:9 (v6); docs: бэклог — виджет фамильяра
- `abae092` docs: бэклог — прогресс достижений на карте и в бою (32:9); журнал
- `3149e65` ui: арена v4 — блоки по краям экрана; tools: генераторы 32:9

**Агент 2**
- `d66a12a` docs: OWNER_TODO.md - единый список задач для владельца; AGENTS.md: правила заполнения; README, журнал
- `c765b92` mods: map-stats-test (поля статистики в нижней панели карты); tools: Find-KBText.ps1; docs: план 'предметы на карте', roadmap, журнал
- `55f427d` ui: кольцо прогресса загрузки на 3 px выше, ui_nudge.py и NUDGE в gen.py; docs: полный снимок Legend перенесён из ветки, журнал
- `ecebe60` tools: Get-KBManifest.ps1 - манифест и сравнение всех игр одним запуском (без Python); docs: роль агента 2, листинг kfs Legend, журнал

**Агент 1**
- `56c9653` mods: medal-slots-ui (hero.ui + 6 слотов медалей), схема hero.ui Legend, roadmap (архив агента 1, залит агентом 2)

**Владелец (vlsek)**
- `6278326` Add files via upload
- `c6f752d` Update WORKLOG.md
- `1c442b2` Update ROADMAP.md
- `6b5e5a4` Add files via upload
- `4ccd659` Add files via upload

**Агент 5**
- `3800070` docs: схема окна героя Legend и свободные зоны под слоты медалей
- `3c1876d` gameplay: medal-slots-test (этап 1), docs: слоты 9-12 = слоты жены, журнал
- `afde7c1` docs: слоты под медали - что известно и что проверить
- `8fb616d` docs: план достижений в Legend без новых форм (путь A/B)
- `c07d2e9` docs: достижения в exe - классов форм нет в Legend kb.exe, варианты; журнал
- `a07b158` docs: исследование графики (game.ini, DXVK/dgVoodoo2), 32:9 проверен владельцем, журнал

## 2026-11-24
**Claude (координатор)**
- `f05472b` ui: мод 32:9 v4; docs: реальная структура игр, .kfs как zip, новые скрипты
- `20bcb89` docs: структура папки игры и скрипт снимка структуры
- `a02b9dd` repo: структура координации, правила для агентов, мод 32:9 v3

**Агент 4**
- `d80eeeb` achievements-test v3: тестовый порог 1
- `19e20bf` achievements-test v2: include в items.txt; бэклог: злобоглаз, UI достижений
- `0a0d807` mods: achievements-test (пробное достижение Высший маг)
- `e5acc8c` docs: достижения всей серии (DS, WotN, CW, RS), тексты, классификация
- `a2800fc` docs: kfs=zip, достижения WotN, карта скриптов Legend; tools: kfs_unpack

**Агент 5**
- `3502c8d` docs: дампы всех игр серии (GOG), находки; правила: всем агентам можно пушить в main
