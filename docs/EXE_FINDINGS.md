# Что внутри exe: достижения (агент 5)

Источник: `docs/dumps/exe_search_2026-11-25.txt` (результат `tools/search_kfs.ps1` по строкам `achiev` во всех exe GOG-установок).

## Факты
| exe | попаданий `achiev` |
|---|---|
| `KBWotN.exe` (WotN) | 52 |
| `KBDarkside.exe` (Dark Side) | 49 |
| `kb.exe` Legend EE | **0** |
| `kb.exe` Crossworlds, `kb.exe` Red Sands | 0 |
| `Editor.exe` (CW, RS) | 0 |

В WotN и Dark Side в exe есть C++-классы (RTTI) формы достижений:
`game_form_achievements_c`, `game_form_new_achievement_c`, `game_form_post_achievement_c`,
`achievement_processing_c`, `new_achievement_processing_c`, `post_achievement_processing_c`,
`achievement_page_listener_c`, `turn_achievement_delayed_c`.
Исходник в пути: `\game\forms\ui_game_form_new_achievement.cpp`. Там же имена `achievement_unlocked`,
`achievement_posted_success/fail` и (WotN) `achievement.php` - публикация в соцсети (кнопки fb/tw/vk в `new_achievement.ui`).
Все 22 имени медалей `medal_achievement_*_1` тоже зашиты в exe (WotN), а в `kb.exe` Legend нет ничего.

## Вывод
Имя формы в `forms.txt` (`form=achievements`) соответствует классу в exe (`game_form_achievements_c`) - соответствие имён ✓, что именно так движок их сопоставляет ❓ (вывод по именам).
В `kb.exe` Legend таких классов нет, поэтому форма `achievements`, добавленная в `forms.txt`, движку неизвестна - **кнопка без реакции ожидаема**. Правка `.ui` и `forms.txt` этого не исправит: логика окна, всплывашки и подсчёта живёт в коде exe, а не в данных.
Подсчёт `ma_*` переменных тоже в коде (в скриптах и данных WotN нашлись только описания в `achievements.txt`) ❓.

## Что остаётся (варианты)
1. **Без новых форм (данные + скрипты Legend):** награды как предметы/медали + текстовые сообщения при получении, список в существующем окне (книга, записи/`records`, окно героя). Нужно проверить, какие формы Legend уже умеет открывать и наполнять скриптом.
2. **Перенос кампании Legend в более новый exe** (WotN/Dark Side), где достижения уже есть. ❓ Неизвестно, запустит ли новый exe данные Legend (`sessions\base`). Проверка дешёвая, на копии папки игры.
3. Патч exe - не планируем (риск, нет исходников, правило репо про файлы игры).
