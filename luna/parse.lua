local insert = table.insert
local concat = table.concat
local format = string.format

local inspect = require 'inspect'

return function(tokens)
  local current = 1

  local walk

  local function advance()
    current = current + 1
  end

  local function checkToken(...)
    local token = tokens[current]
    if not token then return false end
    for i=1, select('#', ...) do
      if token.type == select(i, ...) then
        return token
      end
    end
    return false
  end

  local function skipToken(...)
    local token = checkToken(...)
    if token then
      advance()
      return token
    end
    return false
  end

  local function parseBodyUntil(func, ...)
    local body = {}
    while not func(...) do
      local exp = walk()
      if exp then
        insert(body, exp)
      end
    end
    return body
  end

  function walk()

    -- if expression
    if skipToken('if') then
      local cases = {}

      local condition = walk()
      if condition and skipToken('then') then
        insert(cases, {
          type = 'condition',
          condition = condition,
          body = parseBodyUntil(checkToken, 'elseif', 'else', 'end'),
        })
      end

      while skipToken('elseif') do
        local condition = walk()
        if condition and skipToken('then') then
          insert(cases, {
            type = 'condition',
            condition = condition,
            body = parseBodyUntil(checkToken, 'else', 'end'),
          })
        end
      end

      while skipToken('else') do
        insert(cases, {
          type = 'default',
          body = parseBodyUntil(checkToken, 'end')
        })
      end

      return skipToken('end') and { type = 'conditional-expression', cases = cases }
    end

    -- do expression
    if skipToken('do') then
      return {
        type = 'block-expression',
        body = parseBodyUntil(skipToken, 'end'),
      }
    end

    -- infix expression
    if skipToken('infix-open') then
      local exp = walk()
      if exp and skipToken('infix-close') then
        return { type = 'infix', value = exp }
      end
    end

    -- literals
    local literal = skipToken(
      'literal-name',
      'literal-number',
      'literal-string',
      'literal-constant',
      'literal-vararg')

    if literal then
      return { type = literal.type, value = literal.value }
    end
  end

  local tree = { type = 'block', body = {} }

  while current <= #tokens do
    local node = walk()
    if node then
      insert(tree.body, node)
    else
      local token = tokens[current] or { type = 'eof', value = '<eof>' }
      error(format('unexpected token %q at position %d', token.value, current))
    end
  end

  return tree
end
