local lexer = require 'lexer'

local function isArray(tab)
  local len = 0
  for key in pairs(tab) do
    if type(key) == 'string' or len > #tab then
      return false
    else
      len = len + 1
    end
  end
  return true
end

local function isDeepTable(tab)
  for _, value in pairs(tab) do
    if type(value) == 'table' then
      return true
    end
  end
  return false
end

local function escapeKey(key)
  if key:match('[%a_][%w_]*') == key then
    return key
  else
    return table.concat{'[', tostring(key), ']'}
  end
end

local function pprint(value)
  local level = 0
  local output = {}

  local function append(...)
    if select('#', ...) > 1 then
      table.insert(output, table.concat{...})
    else
      table.insert(output, ...)
    end
  end

  local function indent()
    return string.rep('  ', level)
  end

  local function recprint(value)
    if type(value) ~= 'table' then
      if type(value) == 'string' then
        append(string.format('%q', value))
      else
        append(tostring(value))
      end
    elseif isArray(value) or isDeepTable(value) then
      append(indent(), '{\n')
      level = level + 1
      for i,v in ipairs(value) do
        append(indent())
        recprint(v)
        append(',\n')
      end
      for k,v in pairs(value) do
        if type(k) == 'string' then
          append(escapeKey(k), ' = ')
          recprint(v)
          append(',\n')
        end
      end
      level = level - 1
      append(indent(), '}')
    else
      append(indent(), '{ ')
      for i,v in ipairs(value) do
        recprint(v)
        append(', ')
      end
      for k,v in pairs(value) do
        if type(k) == 'string' then
          append(escapeKey(k), ' = ')
          recprint(v)
          append(', ')
        end
      end
      append('}')
    end
  end

  recprint(value)
  print(table.concat(output))
end


local source = [[let notlet letnot "hell\"o world" 'test' 123 foobar]]

local tokens, err = lexer.tokenize(source)
pprint(tokens or err)
