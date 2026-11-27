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
      for k, v in pairs(t) do table.insert(keys, tostring(k) .. ":" .. type(v)) end
      table.sort(keys)
      return keys
    end
    local function dump(label, obj)
      local ty = type(obj)
      if ty == "table" then
        add(label .. " [table] " .. table.concat(names_of(obj), " "))
      elseif ty == "userdata" then
        local mt = getmetatable(obj)
        add(label .. " [userdata] metatable=" .. type(mt))
        if type(mt) == "table" then
          add(label .. ".metatable " .. table.concat(names_of(mt), " "))
          if type(mt.__index) == "table" then add(label .. ".__index " .. table.concat(names_of(mt.__index), " ")) end
        end
      else
        add(label .. " [" .. ty .. "]")
      end
    end
    add("KB2026 API DUMP tag=" .. tostring(tag))
    add("lua_version=" .. tostring(_VERSION))
    add("io=" .. type(io) .. " os=" .. type(os) .. " loadstring=" .. type(loadstring) .. " getmetatable=" .. type(getmetatable) .. " string=" .. type(string) .. " math=" .. type(math))
    -- every global table / userdata = an API namespace (Game, Logic, Attack, ...)
    local globals = {}
    for k, v in pairs(_G) do
      local t = type(v)
      if t == "table" or t == "userdata" then table.insert(globals, tostring(k)) end
    end
    table.sort(globals)
    add("GLOBAL_NAMESPACES " .. table.concat(globals, " "))
    for i = 1, table.getn(globals) do
      local nm = globals[i]
      local pk, e2 = pcall(function() dump(nm, _G[nm]) end)
      if not pk then add(nm .. " dump error: " .. tostring(e2)) end
    end
    -- global FUNCTIONS (names only): shows which engine/script functions exist at top level
    local gf = {}
    for k, v in pairs(_G) do
      if type(v) == "function" then table.insert(gf, tostring(k)) end
    end
    table.sort(gf)
    add("GLOBAL_FUNCTIONS " .. table.concat(gf, " "))
    local text = table.concat(out, "\n")
    local wrote = "no"
    if io and io.open then
      local o2, f = pcall(function() return io.open("@@OUTFILE@@", "w") end)
      if o2 and f then
        pcall(function() f:write(text); f:close() end)
        wrote = "@@OUTFILE@@"
      end
    end
    local head = "APIDUMP lines=" .. table.getn(out) .. " chars=" .. string.len(text) .. " file=" .. wrote
    if wrote == "no" then
      local pos = 1
      local n = 0
      while pos <= string.len(text) and n < 4 do
        pcall(function() Game.MessageBox(head .. "\n" .. string.sub(text, pos, pos + 1500)) end)
        pos = pos + 1501
        n = n + 1
      end
    else
      pcall(function() Game.MessageBox(head) end)
    end
  end)
  if not ok then pcall(function() Game.MessageBox("APIDUMP error: " .. tostring(err)) end) end
end
