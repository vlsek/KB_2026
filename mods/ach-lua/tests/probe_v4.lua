
-- KB_2026 lua-probe (agent 4): shows once which script APIs exist. Lua 5.0 style (no # operator).
kb2026_probe_done = nil
function kb2026_probe(tag)
  if kb2026_probe_done then return end
  kb2026_probe_done = true
  if type(pcall) ~= "function" then
    if Game and Game.MessageBox then Game.MessageBox("PROBE: pcall is not available") end
    return
  end
  local ok, err = pcall(function()
    local r = {}
    local function t(n, v) table.insert(r, n .. "=" .. type(v)) end
    t("Game.GVNum", Game.GVNum)
    t("Game.GVNumInc", Game.GVNumInc)
    t("Game.GVSNum", Game.GVSNum)
    t("Game.MessageBox", Game.MessageBox)
    t("Game.InfoHint", Game.InfoHint)
    t("Game.InvokeMsgBox", Game.InvokeMsgBox)
    t("Rec", Rec)
    t("Logic.hero_add_item", Logic.hero_add_item)
    t("Logic.hero_lu_item", Logic.hero_lu_item)
    t("Logic.hero_remove_item", Logic.hero_remove_item)
    local names = { "res_crystals_received", "runes_might_received", "damage_magic", "battles_count", "enemy_units_killed" }
    for i = 1, table.getn(names) do
      local nm = names[i]
      local ok2, v = pcall(function() return Game.GVNum(nm) end)
      table.insert(r, nm .. "=" .. tostring(ok2) .. ":" .. tostring(v))
    end
    local okadd, erradd = pcall(function() Logic.hero_add_item("medal_test_ok") end)
    table.insert(r, "hero_add_item(medal_test_ok)=" .. tostring(okadd) .. ":" .. tostring(erradd))
    local s = "PROBE " .. tag .. " " .. table.concat(r, " | ")
    local ok3 = pcall(function() Game.MessageBox(s) end)
    if not ok3 then pcall(function() Game.InfoHint(s) end) end
  end)
  if not ok then pcall(function() Game.MessageBox("PROBE error: " .. tostring(err)) end) end
end
