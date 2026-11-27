-- KB_2026 lua-api-dump (agent 5): ONCE per game start (first chest/box) dumps the names of all script API functions
-- to a text file and shows a short message. Lua 5.0 style (no # operator). ASCII only. Changes nothing in the game.
kb2026_apidump_done = nil
function kb2026_apidump(tag)
  if kb2026_apidump_done then return end
  kb2026_apidump_done = true
  local ok, err = pcall(function()
    local out = {}
    local function add(s) table.insert(out, s) end
    local function names_of(t)
      local keys = {}
      if type(t) == "table" then
        for k, v in pairs(t) do table.insert(keys, tostring(k) .. ":" .. type(v)) end
      end
      table.sort(keys)
      return table.concat(keys, " ")
    end
    local function selected_names(t, terms)
      local keys = {}
      if type(t) == "table" then
        for k, v in pairs(t) do
          local name = string.lower(tostring(k))
          local keep = false
          for i = 1, table.getn(terms) do
            if string.find(name, terms[i], 1, true) then keep = true end
          end
          if keep then table.insert(keys, tostring(k) .. ":" .. type(v)) end
        end
      end
      table.sort(keys)
      return table.concat(keys, " ")
    end
    add("KB2026 API PROBE tag=" .. tostring(tag))
    add("lua_version=" .. tostring(_VERSION))
    add("io=[" .. names_of(io) .. "]")
    add("os=[" .. names_of(os) .. "]")
    local terms = {"item", "artifact", "artefact", "equip", "slot", "inventory", "medal", "reward"}
    local namespaces = {"Game", "Logic", "Obj", "Bonus", "Hero"}
    for i = 1, table.getn(namespaces) do
      local name = namespaces[i]
      if type(_G[name]) == "table" then
        add(name .. "=[" .. selected_names(_G[name], terms) .. "]")
      end
    end
    local function result_text(label, ok, value)
      local detail = tostring(value)
      if type(value) == "table" then detail = "table:" .. names_of(value) end
      add(label .. "=" .. tostring(ok) .. ":" .. type(value) .. ":" .. detail)
    end
    local ok1, v1 = pcall(function() return Logic.hero_lu_slots() end)
    result_text("CALL hero_lu_slots()", ok1, v1)
    local ok2, v2 = pcall(function() return Logic.hero_lu_item_on_body("medal_test_ok") end)
    result_text("CALL hero_lu_item_on_body(medal_test_ok)", ok2, v2)
    local ok3, v3 = pcall(function() return Logic.hero_lu_item("medal_test_ok", "count") end)
    result_text("CALL hero_lu_item(medal_test_ok,count)", ok3, v3)
    local ok4, v4 = pcall(function() return Logic.hero_lu_item_query("medal_test_ok") end)
    result_text("CALL hero_lu_item_query(medal_test_ok)", ok4, v4)
    local text = table.concat(out, "\n")
    local chunk_size = 1200
    local total = string.len(text)
    local pages = math.floor((total + chunk_size - 1) / chunk_size)
    if pages < 1 then pages = 1 end
    local pos = 1
    local page = 1
    while pos <= total and page <= 8 do
      local head = "APIPROBE page=" .. tostring(page) .. "/" .. tostring(pages) .. " chars=" .. tostring(total)
      pcall(function() Game.MessageBox(head .. "\n" .. string.sub(text, pos, pos + chunk_size - 1)) end)
      pos = pos + chunk_size
      page = page + 1
    end
    if pages > 8 then pcall(function() Game.MessageBox("APIPROBE truncated after 8 pages") end) end
  end)
  if not ok then pcall(function() Game.MessageBox("APIPROBE error: " .. tostring(err)) end) end
end
