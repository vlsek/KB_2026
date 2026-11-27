# Agent 1 medal art integration — test stage

Status: **needs-test**. The source archive is user-provided as `KB_repo_updates_agent1.zip`; art binaries are not copied into the public repository.

## What is installed on the test copy

- A loose `data/itextures.dat` override was extracted from that copy's own `data.kfs`, then extended with the archive's `TEX190` map (75 image names).
- The archive's `tex190.dds` is installed as `data/tex190.dds`.
- Only the existing test reward item `kb26_medal_chest_rank1` was changed: image `heroitem_kb26_archmage_1.png`, equipment type `mslot`. This lets the already-tested chest callback, permanent +1 Intellect, and confirmed `mslot` rules exercise the art path together.
- The chosen Archmage icon is a technical placeholder for atlas loading; it does not yet represent a real Archmage trigger or final medal mapping.

## Owner check

Follow T-25 in `OWNER_TODO.md`: start a new game, open the nearby chest, inspect the icon in the backpack, and manually drag it to a slot 13–18. The game has not been launched after this change. Current test checks texture lookup and slot compatibility only; automatic equipment, rank replacement, 19-family grid integration, and bonus stacking remain future work.

## Rollback

Restore `sessions/base/ses/items.txt.kb2026agent1.bak`, then delete the newly added `data/itextures.dat` and `data/tex190.dds`. The original game installation was not touched.

## Why the full Agent 1 KFS was not installed

It requires KBMaster and a compatible `mslot` integration; KBMaster is absent from the current copy. The original installer targets Program Files. This test instead uses the generated atlas and one existing test item, without installing KBMaster or merging all item records. Do not upload the atlas bitmap to the public repository unless redistribution rights are confirmed.
