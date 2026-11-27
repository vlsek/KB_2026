# Medal visuals and item progression — test status

Status: **needs-test**. Agent 1's source archive remains user-provided; game-derived image binaries are not copied into the public repository.

## Agent 1 icon atlas

The owner tested the loose `TEX190` map and `tex190.dds` on the GOG Legend copy. The reward and +1 Intellect from the earlier Lua prototype worked, but the medal showed a gray square. Direct loose atlas loading did not work without KBMaster. Those two loose files were removed; the test medal uses the stock quest-medal icon again.

## Confirmed item/popup path

The owner confirmed that the Legend warning form opened in-game through `Game.InvokeMsgBox` and that the medal's item `mods { intellect=count,1 }` granted +1 while equipped. The direct Lua stat setter was removed. Current tooltip correctly says that the +1 applies while worn.

## Rank replacement test

T-27 is installed on the test copy but has not been run. First chest: grant rank I (+1). Next chest: call `Logic.hero_lu_item_del("kb26_medal_chest_rank1")`, grant rank II (+2), increment saved rank, then show the in-game popup. Rank II still requires manual equipment in this probe. The test checks whether deleting an equipped rank removes its bonus, whether rank II appears, and whether +2 replaces +1 rather than stacking to +3.

Later-series scripts confirm `Logic.hero_lu_item_del(item)` is used to remove items, but behavior for an equipped `mslot` item is not yet proven in Legend. Automatic equipping and preventing manual removal remain unresolved.

Backups for the current rank-replacement test are `*.kb2026rank2.bak` beside the four changed files in the test copy. The original installation was not modified.
