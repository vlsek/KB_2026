# 🧩 Поля интерфейса: что есть в других играх, чего нет в Legend (агент 1)

Источник: `.ui` из `data.kfs` Legend EE, Crossworlds (CW) и Red Sands (RS) (присланы владельцем 2026-11-25; файлы игр не коммитим).
Сравнивались имена объектов (`gui_object_name`) и привязки текстов (`gui_object_text "" "<поле>"`).
DS и WotN: присланные архивы содержали только `temp_bottom.ui` — их `.ui` лежат в `data\declarations.kfs` (нужно извлечь).
Пометка ❓ — гипотеза; ничего не проверялось в игре.

## Что есть в CW/RS и нет в Legend

### Карточка героя (`hero.ui`)
| Блок | Объекты | Что это |
|---|---|---|
| Награды / медали | `text_rewards_title` (текст `hero_rewards_title`), `reward__1..10` (иконки 55×55), `reward_level_1..10` (уровень, 15×15) | **10 слотов наград в карточке героя.** В `records.ui` CW/RS есть `heroitem_medal_*`: fire_mage, headhunter, iron_warrior, strategist, battle_alchemy, blind_rage, dragon_slayer, holy_knight, reptile_slayer, guardian_angel — это и есть «достижения» CW ❓ (медали = предметы героя, иконки подставляются движком в `reward__N`) |
| Питомец | `pet_button` (кнопка 155×143, `hero_pet_01_norm.png`), `pet_zaglushka` (рамка 372×178), `pet_progress_pos` (полоса опыта 113×10, подсказка `btn_pet_EXP_line_hint`), `text_pet_name` (`hero_pet_name`), `text_pet_title` (`hero_pet_title`), `text_pet_level` (`hero_pet_level`) | готовый шаблон виджета питомца: имя, титул, уровень, полоса опыта |
| Класс | `hero_class_icon`, `hero_class_hint` | иконка класса героя |

### Арена (`arena.ui`)
- `pet_button` + `pet_podlozhka` (`bottomright4_long_pet.png`) — кнопка питомца в нижней правой панели боя.
- Лог боя собран из частей: `log_top/center/corner/left` (в Legend одна картинка `log02.png`) — удобно для растягивания на широком экране.
- `bill_gilbert_*` — блок на левой стороне (текст `bill_gilbert_text`, картинка `topleft6.png`) ❓ особый герой/персонаж.

### Карта (`map.ui`)
- `buff_icon` + `buff_text` (поле `buff_turns`) — иконка активного бонуса и число ходов.
- `travel_*` (`travel1`, `travel2`, кнопка) и `fly_button1/2` + `fly_zaglushka` — перемещение/полёт.

## Что есть в Legend, а в CW/RS убрано
`hero.ui`: `b_spirit1..4`, `herwsp_e1..4`, `herwsp_l1..4`, `casket_button`, `red_1..12` (духи, шкатулка). Это механики Legend.

## Выводы для проекта
1. Имена полей (`hero_pet_name`, `buff_turns`, …) **подставляет движок/Lua**, а не `.ui`. Работает ли это в Legend EE (exe 2017) — ❓: нужно проверить, добавив объекты в `hero.ui` и посмотрев, заполнятся ли.
2. Для **виджета фамильяра** есть готовый шаблон (`pet_*`). Остаётся выяснить, использует ли мод `mod_17_Master_101_familiar` те же поля или свои (`.lua` мода).
3. Для **прогресса достижений** в карточке героя есть шаблон `reward__N`. В Legend медалей нет (см. `ACHIEVEMENTS.md`, агент 4): CW делает их предметами `heroitem_medal_*`.
4. Блок `buff_*` на карте можно использовать для индикаторов на нижней панели 32:9.

## Нужно от владельца
Извлечь `.ui` из `declarations.kfs` у Dark Side и WotN (`tools/extract_ui.ps1 -Kfs ...\data\declarations.kfs`) и прислать zip. Там 180 `.ui` и поля достижений WotN.

---
## Дополнение (WotN и Dark Side, 2026-11-25): готовый интерфейс достижений
Из `declarations.kfs` DS/WotN (141 и 181 `.ui`). Файлы игр не коммитим.

| Что | Файлы / объекты | Заметки |
|---|---|---|
| Книга достижений | `achievements.ui` (окно 1081×765, фон `achievement_bg.png`, заголовок `achievement_caption`, листание `next_page`/`prev_page`, закрыть `b_cancel`) | страницы заполняет движок/Lua ❓ |
| Всплывашка «Новое достижение» | `new_achievement.ui` (460×350: `achievement_unlocked`, `achievement_name`, `achievement_description`, кнопки публикации `b_publish_fb/tw/vk`) | публикацию в соцсети убрать ❓ |
| Награды в карточке героя | `hero.ui`: `reward__1..15` (WotN) / `reward__1..20` (DS), `reward_level_N`, `achievements_bar` (полоса прогресса!), `achievement_close_0..2`, `heroitem_achievement_close` | в CW/RS только 10 слотов, здесь 15–20 |
| Итог игры | `endgame*.ui`: `text_score`, `text_days`, `text_kills`, `text_losses`, `text_achievements`, `text_difficulty`, `text_titul` | есть и версия `endgame_1680x945.ui` |
| Рекорды | `records.ui`: статистика героя (`rec_*`, 39–44 поля) | см. ниже |

### Статистика, которую игра уже считает (`records.ui`, Legend)
`rec_battle_num` (боёв), `rec_enemy_killed`, `rec_heroes_killed`, `rec_bosses_killed`, `rec_body_count`, `rec_damage_sum/units/magic/spirits`, `rec_quest`, `rec_units_best`, `rec_units_percent`, `rec_money`, `rec_crystal`, `rec_mana`, `rec_rage`, `rec_leadership`, `rec_attack`, `rec_defence`, `rec_intellect`, `rec_level`, `rec_runes*`, `rec_wife*`, `rec_spirit*` и др.
В WotN/DS/CW добавлены `rec_damage_pet`, `rec_rewards_title`, `rec_titul` (CW ещё `rec_pet_*`).
Значит счётчики для достижений **уже есть в движке** — не нужно придумывать свои.

## Сколько всего «может быть сделано»: источники порогов
1. **Оригинальные достижения Legend в Steam** (все с реальными порогами; сводка из [руководства Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=3688037422)): золото 100 000 / 500 000 / 1 000 000; лидерство 5 000 / 10 000 / 15 000 / 20 000; уровни 10 / 20 / 30; мана 50 / 75 / 100; ярость 50 / 75 / 100; армия ≥1 000 существ; 100 заданий; 6 бывших жён; пройти за ≤30 дней; урон >1 000 за удар; семь воплощений Хааса; сюжетные (12), браки (6), сложность (4), классы (3), квестовые.
2. **Данные самой игры** (`sessions\base`): число заданий (`.qst` 122), карт (`.loc`), существ, предметов — максимум считается по файлам, а не «из головы». Задача агента 4/5.
3. **Статистика с форумов** (идея владельца): общих сводок «статистика на конец игры» пока не найдено. Попытки: блог StopGame (прохождение мага «без потерь»: 30 боёв к 2-му дню, 100 боёв в 1 раунд, ~1 000 000 золота к 7-му дню, 25 уровень к 14-му дню) — полной итоговой таблицы нет; Seaward.Ru (редирект, не прочитан); Fantlab. Нужны ссылки/архивы от владельца (Wayback).
