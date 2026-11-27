# Agent 1 medal art integration — findings and next test

Status: **needs-test**. The source archive is user-provided as `KB_repo_updates_agent1.zip`; game-derived art binaries are not copied into the public repository.

## Atlas attempt result

The owner tested the loose `TEX190` map and `tex190.dds` on the GOG Legend test copy. The existing chest message and one-time +1 Intellect still worked, but the item required manual equipping and showed a gray square instead of art. Direct loose atlas loading did not work in this setup without KBMaster. The test `data/itextures.dat` and `data/tex190.dds` were removed; the item is back on the stock quest-medal image.

## Current test-copy setup

- The chest test medal still has `propbits=mslot`, so it can be manually placed into slots 13–18.
- Its item definition now has `mods { intellect=count,1 }`; the old direct +1 Intellect Lua setter was removed to avoid applying the bonus twice.
- The item hint says the +1 applies while worn. For this interim test the owner must equip it manually.
- The system `Game.MessageBox` was replaced by the game's own `Game.InvokeMsgBox("warning", "<label=kb26_medal_unlocked>")` call. Legend scripts contain real examples of this form, and Russian localization keys were added in `rus_units_specials.lng`.
- A test error uses the same in-game warning form. No `Scenario.formsolo` call was added.

Follow T-26 in `OWNER_TODO.md`: use a new game, open the nearby chest, confirm the native game popup, then manually equip the medal and check the +1 Intellect. Also note whether it can be removed and whether the stat bonus follows equip/removal.

## Rollback

Backups of `items.txt`, `logic_hero.lua`, `rus_items.lng`, and `rus_units_specials.lng` use `.kb2026popup.bak`. To restore the previously tested no-item/Lua-bonus prototype, restore `items.txt.kb2026agent1.bak` and the other three `.kb2026popup.bak` files. The temporary loose atlas files have already been removed. The original installation was never changed.

## Remaining work

The bitmap style remains promising, but the loose atlas approach failed in Legend. The full Agent 1 KFS still depends on KBMaster, which is absent from the test copy, and should not be installed with its original Program Files installer. Automatic slot placement and preventing manual removal remain open; `Logic.hero_lu_item_del(item)` is confirmed in later-series scripts for deleting an old rank, but no auto-equip API has been established.
