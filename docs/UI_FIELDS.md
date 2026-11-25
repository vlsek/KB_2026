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
