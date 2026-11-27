-- KB_2026 achievements v0.3 (agent 1): first achievement in Lua. Lua 5.0 style (no # operator). ASCII only.
-- On every chest/box opening: shows damage_magic and the flag (debug), grants the test medal ONCE per game on the first chest (no condition, mechanics test).
function kb2026_check_ach(tag)
  local ok, err = pcall(function()
    local dm = tonumber(Game.GVNum("damage_magic")) or 0
    local fl = tonumber(Game.GVNum("kb26_ach_mage")) or 0
    local msg = "ACH " .. tag .. " damage_magic=" .. tostring(dm) .. " flag=" .. tostring(fl)
    if fl == 0 then
      Game.GVNumInc("kb26_ach_mage", 1)
      local oka, erra = pcall(function() Logic.hero_add_item("medal_test_ok") end)
      msg = msg .. " | GRANT " .. tostring(oka) .. ":" .. tostring(erra)
    end
    Game.MessageBox(msg)
  end)
  if not ok then pcall(function() Game.MessageBox("KB2026 ach error: " .. tostring(err)) end) end
end
