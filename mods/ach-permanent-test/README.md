# Permanent medal prototype (no equipment item)

This is a disposable gameplay probe for the GOG Legend EE copy. It replaces the existing debug achievement callback in `logic_hero.lua`; it does not alter item definitions, UI, or the original installation.

On the first map chest opened in a **new game**, it:
- stores rank 1 in save-backed `Game.GVNum` state (`kb26_perm_chest_medal_rank`);
- permanently adds +1 Intellect through the same `Logic.hero_lu_item` setter used by the game scripts;
- shows one message naming the new rank and bonus.

Further chest openings should not grant another point or repeat the notification. The old test medal may still be in the backpack; ignore it for this test.

## Install

Close the game first. In PowerShell, from a downloaded/cloned repository folder:

```powershell
.\mods\ach-permanent-test\install.ps1 -GameDir "$env:USERPROFILE\Desktop\KB_test_copy\KB The Legend EE"
```

The installer accepts only a path whose final folders are `KB_test_copy\KB The Legend EE`. It backs up `logic_hero.lua` to `logic_hero.lua.kb2026perm.bak` and preserves the chest callback and APIDUMP section. No administrator shell is needed for the Desktop copy.

## Manual check

1. Start a new game and open the hero screen; note current Intellect.
2. Open the nearby chest. Expect one `KB2026 TEST` message and Intellect +1.
3. Open another chest, if convenient. Expect no second message and no additional Intellect.

Tell us: whether the message appeared, Intellect before/after, and whether a second chest repeated either effect. This probe does not yet add a permanent icon/journal panel; it proves the rank + bonus + notification path first.

## Roll back

```powershell
.\mods\ach-permanent-test\uninstall.ps1 -GameDir "$env:USERPROFILE\Desktop\KB_test_copy\KB The Legend EE"
```

Rollback restores the exact `logic_hero.lua` captured immediately before this prototype was installed.
