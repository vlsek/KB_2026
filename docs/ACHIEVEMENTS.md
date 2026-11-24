# 🏅 Достижения серии (агент 4)

Источник: `Warriors of the North\sessions\addon\ses.kfs` → `achievements.txt` (27 записей), `medals.txt`, `forms.txt`;
`Dark Side\data\declarations.kfs` → `achievements.ui`, `new_achievement.ui`, `post_achievement.ui`.

## Как устроены
- **Это не Steam-достижения, а игровые «медали-предметы»** (`propbits=medal`, категория `o`), живут в логике сессии.
  Значит работают и в GOG-версии, и без Steam.
- Запись: `image`, `label`/`hint` (ключи локализации `itm_<имя>_name/_hint`), `params { max, order, var }`
  и `medc=` — скомпилированное выражение (hex), сравнивающее счётчик `var` с `max`.
- Счётчики `var` (`ma_*`, плюс `damage_magic`, `chest_gather`) обновляются из Lua боя:
  `arena.lua`, `addon_arena.lua`, `boss.lua`, `addon_rewards.lua`.
- UI: формы `achievements`, `post_achievement`, `new_achievement` в `forms.txt` → `.ui` в `declarations.kfs`.
- Обычные медали (`medals.txt`, напр. `medal_strategist_1` с тремя порогами `max1..3`) — отдельная, старая система.

## Список (27), порядок `order`
| # | Медаль | Счётчик `var` | Порог |
|---|---|---|---|
| 16 | enemy_of_all_life | ma_enemy_of_all_life | 1 000 000 |
| 17 | cormorant | ma_cormorant | 10 000 000 |
| 18 | god_of_war | ma_god_of_war | — (флаг) |
| 19 | exterminator | ma_exterminator | 250 |
| 20 | munchkin | ma_munchkin | 75 |
| 21 | minion_of_valhalla | ma_minion_of_valhalla | 4 |
| 22 | arachnofob | ma_arachnofob | — |
| 23 | butcher | ma_butcher | 25 |
| 24 | heartless | ma_heartless | 10 000 |
| 25 | reliable_assistant | ma_reliable_assistant | 6 |
| 26 | mental_madman | damage_magic | 500 000 |
| 27 | connoisseur_of_antiquities | ma_connoisseur_of_antiques | — |
| 28 | jewelry_lover | chest_gather | 250 |
| 29 | favorite_valkyries | ma_favorite_valkyries | 5 |
| 30 | big_gun | ma_big_gun | 70 |
| 31 | almost_sacred | ma_almost_sacred | — |
| 32 | enemy_dead | ma_enemy_dead | — |
| 33 | erik_winner | ma_erik_winner_win | — |
| 34 | inspired | ma_inspired | 15 |
| 35 | nice_player | ma_nice_player | 15 |
| 36 | true_warrior | ma_true_warrior | 50 |
| 37 | mage_commander | ma_mage_commander | 50 |
| 38 | troubleseeker | ma_troubleseeker | 500 000 |
| 39 | winner | ma_winner | — |
| 40 | adventurer | ma_adventurer | — |
| 41 | nerd | ma_nerd | — |
| 42 | hardcore_gamer | ma_hardcore_gamer | — |

(`order` 1–15 заняты обычными медалями.) Часть достижений WotN привязана к её сюжету
(Эрик, Гилфорд, валькирии, Агвар) — в Legend они бессмысленны, переносить стоит только универсальные.

## План переноса в Legend
1. **Универсальные** (счётчики боя): exterminator, butcher, heartless, cormorant, enemy_of_all_life, mental_madman,
   troubleseeker, jewelry_lover, true_warrior, mage_commander, hardcore_gamer, winner, nerd.
2. Скопировать записи в слой мода (`mods/<имя>/…/achievements.txt`), подключить форму в `forms.txt`,
   добавить `.ui` из Dark Side (в них есть варианты разрешений) и тексты локализации.
3. **Главный риск:** счётчики `ma_*` увеличиваются кодом Lua WotN (`arena.lua` там 273 КБ против 112 КБ в Legend).
   Надо вставить в Legend-овский `arena.lua` только строки инкремента, не трогая остальное. Без проверки в игре
   считать нерабочим (`status:needs-test`).
4. Картинки `heroitem_achievement_*.png` лежат в `interface_textures`/`textures` WotN — распаковать отдельно.

Файлы игры в репозиторий не кладём — здесь только разбор.
