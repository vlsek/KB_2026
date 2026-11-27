-- KB_2026 permanent medal prototype. Lua 5.0 compatible; ASCII-only source.
-- First chest opened: persist rank 1 and apply +1 Intellect once.
function kb2026_check_ach(tag)
  local ok, err = pcall(function()
    local rank = tonumber(Game.GVNum("kb26_perm_chest_medal_rank")) or 0
    if rank >= 1 then return end

    local intellect = tonumber(Logic.hero_lu_item("intellect", "count")) or 0
    Logic.hero_lu_item("intellect", "count", intellect + 1)
    Game.GVNumInc("kb26_perm_chest_medal_rank", 1)
    Game.MessageBox("KB2026 TEST: Chest medal rank I unlocked. Permanent Intellect +1.")
  end)
  if not ok then
    pcall(function() Game.MessageBox("KB2026 TEST ERROR: " .. tostring(err)) end)
  end
end
