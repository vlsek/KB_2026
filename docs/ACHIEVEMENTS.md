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

---

## Сводка по всей серии (обновление, агент 4)

Источники: `ses.kfs` + `loc_ses.kfs` Dark Side и WotN, `medals.txt` Crossworlds / Red Sands.
Русские названия — `rus_items.lng` (`itm_[medal_]achievement_<имя>_1_name`), описания — `rus_rewards.lng` (`reward_achievement_<имя>`).
Файлы локализации в **UTF-16** (с BOM) — читать/писать только так. DS `achievements.txt` и `medals.txt` — тоже UTF-16.

### Две системы
1. **Достижения** (`achievements.txt`): WotN — 27, **Dark Side — 38** (на 18 больше, часть про отделы/компаньонов/расы). В Crossworlds и Red Sands файла достижений **нет**.
2. **Медали** (`medals.txt`, многоуровневые `_1.._4`): Crossworlds 42, WotN 63, Red Sands 56, DS (есть). Общие: strategist, headhunter, dragon_slayer, treasure_searcher, guardian_angel, battle_alshemy, trapper, undead_slayer, iron_warrior, fire_mage, holy_knight, stupid_slayer, blind_rage, reptile_slayer. Новое в WotN: fat_cat, talanted_warrior, crystals_collector, humble_follower, mental_executor, true_einherian, vampire_slayer, angry_tribesman.
3. **В Legend нет ни `medals.txt`, ни `achievements.txt`** (в `items.txt` нет ни одной записи `propbits=medal`). Значит система медалей в Legend не используется; **поддерживает ли её движок Legend EE — неизвестно**. Это первая вещь для проверки в игре.

### Описание счётчиков — различия между играми
Пороги отличаются: например «Враг всего живого» в DS = 100 000 урона, в WotN = 1 000 000; «Истребитель» 100 против 250; «Коллекционер» 50 против 75. Для Legend пороги берём по WotN или подбираем.

### A. Универсальные счётчики — первые кандидаты в Legend
| Имя | Название | Условие | Откуда |
|---|---|---|---|
| `enemy_of_all_life` | Враг всего живого | Нанести суммарно 1,000,000 урона. | DS+WotN |
| `cormorant` | Жадина | Накопить в кошельке не менее 10,000,000 золота. | DS+WotN |
| `exterminator` | Истребитель | Уничтожить 250 вражеских отрядов. | DS+WotN |
| `heartless` | Бессердечный | Потерять 10,000 своих войск. | DS+WotN |
| `mental_madman` | Высший маг | Нанести 500,000 урона магией за всю игру. | DS+WotN |
| `troubleseeker` | Искатель неприятностей | Получить за игру 500,000 урона. | DS+WotN |
| `jewelry_lover` | Любитель драгоценностей | Собрать 250 сундуков во время странствий. | DS+WotN |
| `munchkin` | Коллекционер | Собрать 75 артефактов и вещей за игру. | DS+WotN |
| `butcher` | Мясорубщик | Уничтожить 25 отрядов врага подряд без пополнения своей армии. | DS+WotN |
| `mage_commander` | Безрассудный боец | Победить в 50 боях без использования Книги магии. | DS+WotN |
| `big_gun` | Мастер игры | Прокачать персонажа до максимального уровня. | DS+WotN |
| `connoisseur_of_antiquities` | Ценитель раритетов | Собрать любой из наборов вещей полностью. | DS+WotN |

### B. Мета / зависят от механик WotN — после A
(`true_warrior` требует талантов Ярости, `inspired` — веток талантов, `nice_player` — самих медалей; `winner`/`adventurer`/`nerd` — сумма других достижений.)

| Имя | Название | Условие | Откуда |
|---|---|---|---|
| `inspired` | Вдохновенный | Получить все таланты в ветке своего класса (хотя бы до 1 уровня). | DS+WotN |
| `nice_player` | Чемпион | Получить 15 медалей в игре (хотя бы 1 уровня). | DS+WotN |
| `winner` | Победитель | Получить достижения "Враг всего живого", "Истребитель", "Мясорубщик", "Хладнокровный воин", "Искатель неприятностей". | DS+WotN |
| `adventurer` | Авантюрист | Получить достижения "Жадина", "Коллекционер", "Бессердечный", "Любитель драгоценностей", "Враг Мёртвых". | DS+WotN |
| `nerd` | Умник | Получить достижения "Баловень Валхаллы", "Высший маг", "Безумство храбрых", "Самоуверенный", "Безрассудный боец". | DS+WotN |
| `true_warrior` | Хладнокровный воин | Победить в 50 боях без использования талантов Ярости. | DS+WotN |

### C. Сюжетные / механики конкретной игры — в Legend не переносим
| Имя | Название | Условие | Откуда |
|---|---|---|---|
| `almost_sacred` | Безумство храбрых | Победить Гилфорда в последнем бою, не используя Книгу магии. | DS+WotN |
| `appearence_deceptive` | Внешность обманчива | Получить в армию огра-девочку | DS |
| `arachnofob` | Арахнофоб | Победить мертвого паука и все его отряды до 15 раунда. | WotN |
| `black_magic_specialist` | Чернокнижник | Выполнить все задания магического отдела | DS |
| `demons_era` | Эпоха демонов | Пройти игру Демонессой на сложности "Нормальная" или выше | DS |
| `deputy_field_marshal` | Вице-Фельдмаршал | Выполнить все задания военного отдела | DS |
| `enemy_dead` | Враг мертвых | Победить Рунорма и закрыть Портал Тьмы, потеряв не более 30% своих войск или не потеряв при этом ни одного отряда. | WotN |
| `enthraller` | Поработитель | Захватить 10000 Пленных | DS |
| `erik_winner` | Самоуверенный | Победить Эрика с минимальным набором союзников. | WotN |
| `favorite_valkyries` | Фаворит валькирий | Прокачать всех валькирий до 5 уровня. | WotN |
| `god_of_war` | Бог войны | Победить Локи до 10 раунда. | DS+WotN |
| `good_engineer` | Почётный инженер | Выполнить все задания инженерного отдела | DS |
| `great_artefact_collector` | Великий собиратель артефактов | Пройти игру, имея все 12 Великих артефактов Нетаны | DS |
| `great_artifacts_power` | В великих артефактах великая мощь | Собрать все 12 Великих артефактов Нетаны | DS |
| `hardcore_gamer` | Вестник Рагнарёка | Пройти игру на невозможном уровне сложности. | DS+WotN |
| `idol` | Кумир | Организовать фан-клуб | DS |
| `innovation_enthusiast` | Энтузиаст инноваций | Выполнить все задания отдела экспериментальных вооружений | DS |
| `large_entourage` | Большая свита | Собрать всех компаньонов | DS |
| `master_trainer` | Мастер-тренер | Увеличить 2 любых характеристики войск до максимума | DS |
| `minion_of_valhalla` | Баловень Валхаллы | Прокачать всех присоединившихся к игроку валькирий до 3 уровня до похода в Демонис | WotN |
| `no_limit_to_perfection` | Нет предела совершенству | Увеличить все доступные к увеличению характеристики войск как минимум до 3 | DS |
| `ph_d` | Кандидат наук | Выполнить все задания научного отдела | DS |
| `reliable_assistant` | Друг гномов | Выполнить все основные и второстепенные задания в Новом Кордаре. | WotN |
| `strength_and_rage` | Сила и ярость | Пройти игру Орком на сложности "Нормальная" или выше | DS |
| `transformations_master` | Мастер превращений | Получить в армию метаморфа | DS |
| `undead_will_live` | Нежить будеть жить | Пройти игру Вампиром на сложность "нормальная" или выше | DS |

### Где лежит текст для мода
- Названия: ключи `itm_medal_achievement_<имя>_1_name` (WotN) / `itm_achievement_<имя>_1_name` (DS) в `rus_items.lng`; в `_hint` стоит `^?^[medal]` — подсказка собирается скриптом (`gen_itm_medal_hint` в `addon_rewards.lua`).
- Условие и подпись счётчика: `reward_achievement_<имя>` и `reward_achievement_<имя>_cond` в `rus_rewards.lng`.
- Окно: `achievement_caption`, `achievement_book_close_hint` в `rus_windows.lng`; счётчик на стене: `rec_achievements_wall` в `rus_records.lng`.
- У Legend `rus_items.lng` (UTF-16) — проверено, формат тот же.

### Иконки
Получено 55 PNG: `heroitem_achievement_<имя>.png` + вариант `_dis` (не получено) + `heroitem_achievement_close.png`. В репозиторий не кладём (ресурсы игры).
