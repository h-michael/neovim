-- Functions shared by Nvim and its test-suite.
--
-- The singular purpose of this module is to share code with the Nvim
-- test-suite. If, in the future, Nvim itself is used to run the test-suite
-- instead of "vanilla Lua", these functions could move to src/nvim/lua/vim.lua

local vim = {}

--- Returns a deep copy of the given object. Non-table objects are copied as
--- in a typical Lua assignment, whereas table objects are copied recursively.
---
--@param orig Table to copy
--@returns New table of copied keys and (nested) values.
function vim.deepcopy(orig) end  -- luacheck: no unused
vim.deepcopy = (function()
  local function _id(v)
    return v
  end

  local deepcopy_funcs = {
    table = function(orig)
      local copy = {}
      for k, v in pairs(orig) do
        copy[vim.deepcopy(k)] = vim.deepcopy(v)
      end
      return copy
    end,
    number = _id,
    string = _id,
    ['nil'] = _id,
    boolean = _id,
  }

  return function(orig)
    return deepcopy_funcs[type(orig)](orig)
  end
end)()

--- Splits a string at each instance of a separator.
---
--@see |vim.split()|
--@see https://www.lua.org/pil/20.2.html
--@see http://lua-users.org/wiki/StringLibraryTutorial
---
--@param s String to split
--@param sep Separator string or pattern
--@param plain If `true` use `sep` literally (passed to String.find)
--@returns Iterator over the split components
function vim.gsplit(s, sep, plain)
  assert(type(s) == "string", string.format("Expected string, got %s", type(s)))
  assert(type(sep) == "string", string.format("Expected string, got %s", type(sep)))
  assert(type(plain) == "boolean" or type(plain) == "nil", string.format("Expected boolean or nil, got %s", type(plain)))

  local start = 1
  local done = false

  local function _pass(i, j, ...)
    if i then
      assert(j+1 > start, "Infinite loop detected")
      local seg = s:sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s:sub(start)
    end
  end

  return function()
    if done then
      return
    end
    if sep == '' then
      if start == #s then
        done = true
      end
      return _pass(start+1, start)
    end
    return _pass(s:find(sep, start, plain))
  end
end

--- Splits a string at each instance of a separator.
---
--- Examples:
--- <pre>
---  split(":aa::b:", ":")     --> {'','aa','','bb',''}
---  split("axaby", "ab?")     --> {'','x','y'}
---  split(x*yz*o, "*", true)  --> {'x','yz','o'}
--- </pre>
--
--@see |vim.gsplit()|
---
--@param s String to split
--@param sep Separator string or pattern
--@param plain If `true` use `sep` literally (passed to String.find)
--@returns List-like table of the split components.
function vim.split(s,sep,plain)
  local t={} for c in vim.gsplit(s, sep, plain) do table.insert(t,c) end
  return t
end

--- Return a list of all keys used in a table.
--- However, the order of the return table of keys is not guaranteed.
---
--@see From https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
--@param t Table
--@returns list of keys
function vim.tbl_keys(t)
  assert(type(t) == 'table', string.format("Expected table, got %s", type(t)))

  local keys = {}
  for k, _ in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

--- Return a list of all values used in a table.
--- However, the order of the return table of values is not guaranteed.
---
--@param t Table
--@returns list of values
function vim.tbl_values(t)
  assert(type(t) == 'table', string.format("Expected table, got %s", type(t)))

  local values = {}
  for _, v in pairs(t) do
    table.insert(values, v)
  end
  return values
end

--- Checks if a list-like (vector) table contains `value`.
---
--@param t Table to check
--@param value Value to compare
--@returns true if `t` contains `value`
function vim.tbl_contains(t, value)
  assert(type(t) == 'table', string.format("Expected table, got %s", type(t)))

  for _,v in ipairs(t) do
    if v == value then
      return true
    end
  end
  return false
end

-- Returns true if the table is empty, and contains no indexed or keyed values.
--
--@see From https://github.com/premake/premake-core/blob/master/src/base/table.lua
--
--@param t Table to check
function vim.tbl_isempty(t)
  assert(type(t) == 'table', string.format("Expected table, got %s", type(t)))
  return next(t) == nil
end

--- Merges two or more map-like tables.
---
--@see |extend()|
---
--@param behavior Decides what to do if a key is found in more than one map:
---      - "error": raise an error
---      - "keep":  use value from the leftmost map
---      - "force": use value from the rightmost map
--@param ... Two or more map-like tables.
function vim.tbl_extend(behavior, ...)
  if (behavior ~= 'error' and behavior ~= 'keep' and behavior ~= 'force') then
    error('invalid "behavior": '..tostring(behavior))
  end
  local ret = {}
  for i = 1, select('#', ...) do
    local tbl = select(i, ...)
    if tbl then
      for k, v in pairs(tbl) do
        if behavior ~= 'force' and ret[k] ~= nil then
          if behavior == 'error' then
            error('key found in more than one map: '..k)
          end  -- Else behavior is "keep".
        else
          ret[k] = v
        end
      end
    end
  end
  return ret
end

--- Deep merge the values from the tables to the right
-- This is useful for applying changes to deeply nested properties
-- on a map-like table. For instance:
--
-- ```lua
-- local capabilities = {
--  textDocument = {
--    synchronization = {
--      didOpen = false;
--    }
--  }
-- }
-- vim.tbl_deep_merge(capabilities, {
--  textDocument = {
--    synchronization = {
--      didClose = true;
--    }
--  }
-- }) == {
--  textDocument = {
--    synchronization = {
--      didOpen = false;
--      didClose = true;
--    }
--  }
-- }
-- ```
--
-- A map-like table will never be overriden with an empty table, but
-- it can be overriden with another type of value, for instance:
--
-- ```
-- vim.tbl_deep_merge({a={b=1}}, {a={}}) == {a={b=1}}
-- vim.tbl_deep_merge({a={b=1}}, {a=2}) == {a=2}
-- ```
function vim.tbl_deep_merge(dst, ...)
  assert(type(dst) == 'table', 'tbl_deep_merge destination must be a table')
  for i = 1, select("#", ...) do
    local t = select(i, ...)
    assert(type(t) == 'table', 'tbl_deep_merge sources must be tables')
    for k, v in pairs(t) do
      if type(v) == 'table' and not vim.tbl_islist(v) then
        dst[k] = vim.tbl_deep_merge(dst[k] or {}, v)
      else
        dst[k] = v
      end
    end
  end
  return dst
end

--- Deep compare values for equality
function vim.deep_equal(a, b)
  if a == b then return true end
  if type(a) ~= type(b) then return false end
  if type(a) == 'table' then
    -- TODO improve this algorithm's performance.
    for k, v in pairs(a) do
      if not vim.deep_equal(v, b[k]) then
        return false
      end
    end
    for k, v in pairs(b) do
      if not vim.deep_equal(v, a[k]) then
        return false
      end
    end
    return true
  end
  return false
end

--- Add the reverse lookup values to an existing table.
--- For example:
--- `tbl_add_reverse_lookup { A = 1 } == { [1] = 'A', A = 1 }`
--
--Do note that it *modifies* the input.
--@param o table The table to add the reverse to.
function vim.tbl_add_reverse_lookup(o)
  local keys = vim.tbl_keys(o)
  for _, k in ipairs(keys) do
    local v = o[k]
    if o[v] then
      error(string.format("The reverse lookup found an existing value for %q while processing key %q", tostring(v), tostring(k)))
    end
    o[v] = k
  end
  return o
end

--- Extends a list-like table with the values of another list-like table.
---
--NOTE: This *mutates* dst!
--@see |extend()|
---
--@param dst The list which will be modified and appended to.
--@param src The list from which values will be inserted.
function vim.list_extend(dst, src)
  assert(type(dst) == 'table', "dst must be a table")
  assert(type(src) == 'table', "src must be a table")
  for _, v in ipairs(src) do
    table.insert(dst, v)
  end
  return dst
end

--- Creates a copy of a list-like table such that any nested tables are
--- "unrolled" and appended to the result.
---
--@see From https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
--@param t List-like table
--@returns Flattened copy of the given list-like table.
function vim.tbl_flatten(t)
  local result = {}
  local function _tbl_flatten(_t)
    local n = #_t
    for i = 1, n do
      local v = _t[i]
      if type(v) == "table" then
        _tbl_flatten(v)
      elseif v then
        table.insert(result, v)
      end
    end
  end
  _tbl_flatten(t)
  return result
end

-- Determine whether a Lua table can be treated as an array.
---
--@params Table
--@returns true: A non-empty array, false: A non-empty table, nil: An empty table
function vim.tbl_islist(t)
  if type(t) ~= 'table' then
    return false
  end

  local count = 0

  for k, _ in pairs(t) do
    if type(k) == "number" then
      count = count + 1
    else
      return false
    end
  end

  if count > 0 then
    return true
  else
    return nil
  end
end

--- Trim whitespace (Lua pattern "%s") from both sides of a string.
---
--@see https://www.lua.org/pil/20.2.html
--@param s String to trim
--@returns String with whitespace removed from its beginning and end
function vim.trim(s)
  assert(type(s) == 'string', string.format("Expected string, got %s", type(s)))
  return s:match('^%s*(.*%S)') or ''
end

--- Escapes magic chars in a Lua pattern string.
---
--@see https://github.com/rxi/lume
--@param s  String to escape
--@returns  %-escaped pattern string
function vim.pesc(s)
  assert(type(s) == 'string', string.format("Expected string, got %s", type(s)))
  return s:gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', '%%%1')
end

return vim
-- vim:sw=2 ts=2 et
