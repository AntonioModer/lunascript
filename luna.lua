local lexer = require 'lexer'

local inspect = require 'inspect'

local source = [["hell\"o world" "test" 123 foobar]]

local tokens, err = lexer.tokenize(source)

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
    elseif isArray(value) then
      append(indent(), '{\n')
      level = level + 1
      for i,v in ipairs(value) do
        append(indent())
        recprint(v)
        append(',\n')
      end
      level = level - 1
      append(indent(), '}')
    elseif isDeepTable(value) then
      error('deep tables not implemented')
    else
      append(indent(), '{ ')
      for k,v in pairs(value) do
        append(tostring(k), ' = ')
        recprint(v)
        append(', ')
      end
      append('}')
    end
  end

  recprint(value)
  print(table.concat(output))
end

-- print(tokens and inspect(tokens) or err)

pprint(tokens or err)
