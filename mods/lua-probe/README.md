# lua-probe - what can Legend scripts do? (agent 4)

Static analysis shows: Legend has no medal/achievement code in kb.exe (zero hits for `medal`, `medc`, `achievement`), so achievements must be done in Lua (path B in `docs/ACHIEVEMENTS_PLAN.md`). Open questions this probe answers in one click:
1. Does `Game.GVNum` (read a counter) exist? Can scripts read `damage_magic`, `battles_count`, `enemy_units_killed`?
2. Does `Game.MessageBox` work from the map (notification on getting an achievement)?
3. Are `Logic.hero_add_item / hero_lu_item / hero_remove_item` available (give/remove a medal item)?

Install on a COPY of the game: `.\install.ps1 -GameDir "...\KB The Legend EE"`. Start the game, load a save, pick up a chest. A message box `PROBE ...` appears once per game start. Screenshot it (or text) and send it.
Undo: `.\uninstall.ps1 -GameDir "..."`.

| Result | Meaning |
|---|---|
| message box with function types and values | path B is feasible, next: real achievements in Lua |
| no message box, no crash | `MessageBox` does not work from this hook; will try `InfoHint`/battle hook |
| crash on pickup | send log; rollback with uninstall |
