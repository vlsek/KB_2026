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
    local write_error = ""
    local out_path = "@@OUTFILE@@"
    -- Some game builds expose io.open but return file handles without methods.
    -- Prefer Lua's default-output API when available.
    if io and type(io.output) == "function" and type(io.write) == "function" and type(io.close) == "function" then
      local output_ok, output_result, output_err = pcall(io.output, out_path)
      if output_ok and output_result then
        local write_ok, write_result = pcall(io.write, text)
        local close_ok, close_result, close_err = pcall(io.close)
        if write_ok and write_result and close_ok and close_result then
          wrote = out_path .. " bytes=" .. string.len(text)
        else
          if not write_ok then write_error = tostring(write_result)
          elseif not close_ok then write_error = tostring(close_result)
          else write_error = tostring(close_err or "io.write/io.close returned no result") end
        end
      else
        if output_ok then write_error = tostring(output_err or "io.output returned no file")
        else write_error = tostring(output_result) end
      end
    else
      write_error = "io.output/io.write/io.close unavailable"
    end
    -- Fallback for builds where io.open returns a normal Lua file handle.
    if wrote == "no" and io and type(io.open) == "function" then
      local open_ok, f, open_err = pcall(io.open, out_path, "w")
      if open_ok and f then
        local method = nil
        local method_ok, method_value = pcall(function() return f.write end)
        if method_ok then method = method_value end
        if type(method) == "function" then
          local write_ok, write_result = pcall(method, f, text)
          local close_method = nil
          local close_ok, close_value = pcall(function() return f.close end)
          if close_ok then close_method = close_value end
          local closed, close_result = false, nil
          if type(close_method) == "function" then closed, close_result = pcall(close_method, f) end
          if write_ok and write_result and closed then
            wrote = out_path .. " bytes=" .. string.len(text)
            write_error = ""
          else
            write_error = tostring((not write_ok and write_result) or (not closed and close_result) or "file handle write/close failed")
          end
        else
          write_error = "io.open handle has no write method; io output API failed: " .. write_error
        end
      else
        write_error = tostring((open_ok and open_err) or f or "io.open failed")
      end
    end
    local head = "APIDUMP lines=" .. table.getn(out) .. " chars=" .. string.len(text) .. " file=" .. wrote .. " error=" .. write_error
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
