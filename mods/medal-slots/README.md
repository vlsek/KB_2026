# medal-slots - тип слота `mslot` и слоты 13..30 для медалей (агент 4)

Формальная версия того, что владелец подтвердил в игре (`docs/LEGEND_MEDALS_FINDINGS.md`): свой тип слота `mslot`, слоты 13..N, медаль с `propbits=mslot` встаёт только в них.
Статус: **needs-test**. Скрипты проверены в `pwsh` 7 на реальных `hero.txt`/`config.txt` Legend (установка, повтор, удаление, побайтовый откат); в игре - нет.

## Что делает
- `config.txt`: в `propbits` добавляет `mslot=0x1000000` (после `artefact=0x800000`).
- `hero.txt`: во всех трёх классах после `8=artefact` добавляет `13=mslot` ... `(12+N)=mslot`; в `slot_bgs` - `mslot=<фон артефакта>/hero_slot_mslot`.
- `rus_hero.lng`: подсказка типа слота «Медаль достижения».
- Ключ `-TestMedals`: три тестовые медали `kb26_test_medal_1..3` (`propbits=mslot`, иконка квестовой медали) в стартовом рюкзаке новой игры - чтобы сразу попробовать слоты.

## Установка (на КОПИИ)
```powershell
.\install.ps1 -GameDir "<копия>\KB The Legend EE" -TestMedals          # 18 слотов (13..30)
.\install.ps1 -GameDir "<копия>\KB The Legend EE" -Count 6 -TestMedals # только проверенные 13..18
```
Откат: `.\uninstall.ps1 -GameDir "<копия>\KB The Legend EE"` (убирает только свои строки; бэкапы `*.kb2026ms.bak` остаются).

## Важно
- Слоты 13..18 проверены владельцем; **19..30 - новые**, неизвестно, принимает ли их движок. Если игра падает/слоты странные - ставьте `-Count 6`.
- Сами слоты в окне героя рисует `mods/medals-grid` (или `medals-panel`). Без них правила есть, а кнопок нет.
- Совместим с `medal-slots-test` (тот кладёт медали с `propbits=quest`, они в эти слоты НЕ встанут; нужны `propbits=mslot`).
- При активном KBMaster правки `hero.txt`/`config.txt` игнорируются (`docs/KBMASTER_PLAN.md`).
